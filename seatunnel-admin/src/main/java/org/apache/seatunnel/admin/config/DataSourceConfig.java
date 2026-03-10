package org.apache.seatunnel.admin.config;

import com.baomidou.mybatisplus.annotation.DbType;
import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.core.MybatisConfiguration;
import com.baomidou.mybatisplus.core.config.GlobalConfig;
import com.baomidou.mybatisplus.core.handlers.MybatisEnumTypeHandler;
import com.baomidou.mybatisplus.extension.plugins.MybatisPlusInterceptor;
import com.baomidou.mybatisplus.extension.plugins.inner.PaginationInnerInterceptor;
import com.baomidou.mybatisplus.extension.spring.MybatisSqlSessionFactoryBean;
import org.apache.ibatis.logging.stdout.StdOutImpl;
import org.apache.ibatis.mapping.DatabaseIdProvider;
import org.apache.ibatis.mapping.VendorDatabaseIdProvider;
import org.apache.ibatis.session.SqlSessionFactory;
import org.apache.ibatis.type.JdbcType;
import org.mybatis.spring.SqlSessionTemplate;
import org.mybatis.spring.annotation.MapperScan;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.context.annotation.Profile;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;

import javax.sql.DataSource;
import java.util.Properties;

/**
 * Spring configuration for DataSource, MyBatis, and MyBatis-Plus integration.
 * Implements database plugin pattern similar to Apache DolphinScheduler.
 *
 * <p>
 * This configuration sets up:
 * </p>
 * <ul>
 *     <li>Profile-based DataSource configuration</li>
 *     <li>Database-specific MyBatis-Plus configuration</li>
 *     <li>SqlSessionFactory with database ID provider</li>
 *     <li>Transaction management</li>
 *     <li>Database-specific pagination interceptors</li>
 * </ul>
 */
@Configuration
@MapperScan("org.apache.seatunnel.admin.dao") // Scan DAO interfaces for MyBatis
public class DataSourceConfig {

    /**
     * Profile-based DataSource bean.
     * Configuration is loaded from spring.datasource.cockpit properties.
     *
     * @return DataSource instance based on active profile
     */
    @Bean(name = "dataSource")
    @ConfigurationProperties(prefix = "spring.datasource.cockpit")
    @Primary
    public DataSource dataSource() {
        return DataSourceBuilder.create().build();
    }

    /**
     * Global MyBatis-Plus configuration.
     *
     * <p>
     * Configures automatic ID generation strategy and disables the banner.
     * </p>
     *
     * @return GlobalConfig instance
     */
    @Bean(name = "cockpitGlobalConfig")
    public GlobalConfig globalConfig() {
        GlobalConfig globalConfig = new GlobalConfig();
        globalConfig.setBanner(false); // Disable MyBatis-Plus startup banner
        GlobalConfig.DbConfig dbConfig = new GlobalConfig.DbConfig();
        dbConfig.setIdType(IdType.AUTO); // Use auto-increment primary keys
        globalConfig.setDbConfig(dbConfig);
        return globalConfig;
    }

    /**
     * Database ID provider for MyBatis to support database-specific SQL.
     *
     * @return DatabaseIdProvider instance
     */
    @Bean
    public DatabaseIdProvider databaseIdProvider() {
        DatabaseIdProvider databaseIdProvider = new VendorDatabaseIdProvider();
        Properties properties = new Properties();
        properties.setProperty("MySQL", "mysql");
        properties.setProperty("H2", "h2");
        databaseIdProvider.setProperties(properties);
        return databaseIdProvider;
    }

    /**
     * Primary SqlSessionFactory configured with:
     * <ul>
     *     <li>DataSource</li>
     *     <li>Mapper XML locations</li>
     *     <li>MyBatis configuration options (camel-case mapping, logging, enum handler, etc.)</li>
     *     <li>Database-specific MybatisPlusInterceptor with pagination plugin</li>
     *     <li>Database ID provider for database-specific SQL</li>
     * </ul>
     *
     * @param dataSource injected DataSource
     * @param dbType database type for pagination configuration
     * @return SqlSessionFactory instance
     * @throws Exception if bean creation fails
     */
    @Bean(name = "sqlSessionFactory")
    @Primary
    public SqlSessionFactory sqlSessionFactory(
            @Qualifier("dataSource") DataSource dataSource,
            DbType dbType) throws Exception {
        MybatisSqlSessionFactoryBean bean = new MybatisSqlSessionFactoryBean();
        bean.setDataSource(dataSource);
        bean.setMapperLocations(new PathMatchingResourcePatternResolver().getResources("classpath*:mapper/*.xml"));
        bean.setGlobalConfig(globalConfig());
        bean.setDatabaseIdProvider(databaseIdProvider());

        // MyBatis core configuration
        MybatisConfiguration configuration = new MybatisConfiguration();
        configuration.setJdbcTypeForNull(JdbcType.NULL); // Handle null JDBC types
        configuration.setMapUnderscoreToCamelCase(true); // Convert snake_case to camelCase
        configuration.setCacheEnabled(false); // Disable MyBatis second-level cache
        configuration.setLogImpl(StdOutImpl.class); // Enable logging to stdout
        configuration.setDefaultEnumTypeHandler(MybatisEnumTypeHandler.class); // Enum handler
        bean.setConfiguration(configuration);

        // Add database-specific MybatisPlusInterceptor with pagination plugin
        bean.setPlugins(mybatisPlusInterceptor(dbType));
        return bean.getObject();
    }

    /**
     * Configure transaction manager for the primary DataSource.
     *
     * @param dataSource injected DataSource
     * @return DataSourceTransactionManager instance
     */
    @Bean(name = "transactionManager")
    @Primary
    public DataSourceTransactionManager transactionManager(@Qualifier("dataSource") DataSource dataSource) {
        return new DataSourceTransactionManager(dataSource);
    }

    /**
     * Primary SqlSessionTemplate for MyBatis operations.
     *
     * @param sqlSessionFactory injected SqlSessionFactory
     * @return SqlSessionTemplate instance
     */
    @Bean(name = "sqlSession")
    @Primary
    public SqlSessionTemplate sqlSessionTemplate(@Qualifier("sqlSessionFactory") SqlSessionFactory sqlSessionFactory) {
        return new SqlSessionTemplate(sqlSessionFactory);
    }

    /**
     * Database-specific MybatisPlusInterceptor with pagination support.
     * This replaces the deprecated PaginationInterceptor in MyBatis-Plus 3.5+.
     *
     * @param dbType database type for pagination configuration
     * @return MybatisPlusInterceptor instance
     */
    @Bean
    public MybatisPlusInterceptor mybatisPlusInterceptor(DbType dbType) {
        MybatisPlusInterceptor interceptor = new MybatisPlusInterceptor();
        // Add pagination interceptor for specific database type
        interceptor.addInnerInterceptor(new PaginationInnerInterceptor(dbType));
        return interceptor;
    }

    /**
     * MySQL database type bean activated when mysql profile is active.
     *
     * @return DbType.MYSQL
     */
    @Bean
    @Primary
    @Profile("mysql")
    public DbType mysqlDbType() {
        return DbType.MYSQL;
    }

    /**
     * H2 database type bean activated when h2 profile is active.
     *
     * @return DbType.H2
     */
    @Bean
    @Primary
    @Profile("h2")
    public DbType h2DbType() {
        return DbType.H2;
    }
}