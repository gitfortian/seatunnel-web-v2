# Multi-Database Support Guide

This project supports multiple database backends using Spring Profiles, following the plugin pattern similar to Apache DolphinScheduler.

## Database Support

Currently supported databases:
- **H2**: In-memory database for local development and testing
- **MySQL**: Production database

## Configuration Files

The database configuration is separated into profile-specific files:

### Main Configuration
- `application.yml`: Contains general application configuration
- Default profile: `h2` (for local development)

### Database-Specific Configurations
- `application-h2.yml`: H2 database configuration
- `application-mysql.yml`: MySQL database configuration

## Usage

### Local Development (H2 - Default)
```bash
# 默认使用H2数据库，无需额外参数
java -jar seatunnel-admin.jar
```

### Using MySQL Database
```bash
# 方式1: 通过启动参数
java -jar seatunnel-admin.jar --spring.profiles.active=mysql

# 方式2: 通过环境变量
export SPRING_PROFILES_ACTIVE=mysql
java -jar seatunnel-admin.jar

# 方式3: 修改application.yml中的默认profile
# spring.profiles.active: mysql
```

## Profile-Specific Features

### H2 Profile (`h2`)
- In-memory database (data lost when JVM shuts down)
- Automatic table creation
- H2 web console enabled at `/h2-console`
- Memory-based Quartz scheduling
- Fast startup and testing

### MySQL Profile (`mysql`)
- Persistent database storage
- JDBC-based Quartz scheduling
- Production-ready configuration
- Requires external MySQL server

## Database Migration

### H2 to MySQL Migration
1. Export data from H2 (if needed)
2. Create MySQL database and tables
3. Update `application-mysql.yml` with correct connection details
4. Switch profile to `mysql`

### MySQL to H2 Migration
1. Export data from MySQL
2. Switch profile to `h2`
3. Import data if needed

## Configuration Details

### H2 Configuration (`application-h2.yml`)
```yaml
spring:
  config:
    activate:
      on-profile: h2
  datasource:
    cockpit:
      driver-class-name: org.h2.Driver
      url: jdbc:h2:mem:seatunnel_web;DB_CLOSE_DELAY=-1;DB_CLOSE_ON_EXIT=FALSE;MODE=MySQL
      username: sa
      password: 
  h2:
    console:
      enabled: true
      path: /h2-console
  quartz:
    job-store-type: memory
```

### MySQL Configuration (`application-mysql.yml`)
```yaml
spring:
  config:
    activate:
      on-profile: mysql
  datasource:
    cockpit:
      driver-class-name: com.mysql.cj.jdbc.Driver
      url: jdbc:mysql://192.168.1.113:3306/seatunnel_web?useUnicode=true&characterEncoding=utf8&useSSL=false&serverTimezone=GMT%2B8
      username: root
      password: 123456
  quartz:
    job-store-type: jdbc
    properties:
      org:
        quartz:
          jobStore:
            driverDelegateClass: org.quartz.impl.jdbcjobstore.StdJDBCDelegate
```

## Technical Implementation

The implementation follows the plugin pattern:

1. **Profile-based DataSource Beans**: Different DataSource beans are created based on active profiles
2. **Database Type Detection**: DbType beans are provided for MyBatis-Plus configuration
3. **Database ID Provider**: Supports database-specific SQL through MyBatis DatabaseIdProvider
4. **Dynamic Pagination**: Database-specific pagination interceptors
5. **Conditional Configuration**: Quartz and other components configured based on database type

## Troubleshooting

### Common Issues

1. **Profile Not Activated**
   - Check `spring.profiles.active` setting
   - Verify profile-specific configuration files exist

2. **Database Connection Failed**
   - Verify database URL, username, and password
   - Check network connectivity to database server
   - Ensure database service is running

3. **Table Not Found**
   - For H2: Tables are created automatically
   - For MySQL: Run SQL initialization scripts manually

### Debugging

Enable debug logging:
```yaml
logging:
  level:
    org.springframework: DEBUG
    com.zaxxer.hikari: DEBUG
```

## Best Practices

1. **Development**: Use H2 for fast iteration and testing
2. **Staging**: Use MySQL with test data
3. **Production**: Use MySQL with proper backup strategy
4. **Configuration**: Keep sensitive data in environment variables
5. **Migration**: Always backup data before switching databases