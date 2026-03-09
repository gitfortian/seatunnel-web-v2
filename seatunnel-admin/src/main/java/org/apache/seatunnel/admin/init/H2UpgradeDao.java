package org.apache.seatunnel.admin.init;

import org.apache.seatunnel.communal.DbType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

@Service
public class H2UpgradeDao extends UpgradeDao {
    public static final Logger logger = LoggerFactory.getLogger(H2UpgradeDao.class);

    private H2UpgradeDao(DataSource dataSource) {
        super(dataSource);
    }

    @Override
    protected String initSqlPath() {
        return "sql/seatunnel_h2.sql";
    }

    @Override
    public DbType getDbType() {
        return DbType.H2;
    }

    /**
     * determines whether a table exists
     * @param tableName tableName
     * @return if table exist return true，else return false
     */
    @Override
    public boolean isExistsTable(String tableName) {
        ResultSet rs = null;
        Connection conn = null;
        try {
            conn = dataSource.getConnection();
            rs = conn.getMetaData().getTables(null, null, tableName, new String[]{"TABLE"});
            return rs.next();
        } catch (SQLException e) {
            logger.error(e.getMessage(), e);
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                logger.error(e.getMessage(), e);
            }
        }
    }

    /**
     * determines whether a field exists in the specified table
     * @param tableName tableName
     * @param columnName columnName
     * @return if column name exist return true，else return false
     */
    @Override
    public boolean isExistsColumn(String tableName, String columnName) {
        ResultSet rs = null;
        Connection conn = null;
        try {
            conn = dataSource.getConnection();
            rs = conn.getMetaData().getColumns(null, null, tableName, columnName);
            return rs.next();
        } catch (SQLException e) {
            logger.error(e.getMessage(), e);
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            try {
                if (rs != null) {
                    rs.close();
                }
                if (conn != null) {
                    conn.close();
                }
            } catch (SQLException e) {
                logger.error(e.getMessage(), e);
            }
        }
    }
}