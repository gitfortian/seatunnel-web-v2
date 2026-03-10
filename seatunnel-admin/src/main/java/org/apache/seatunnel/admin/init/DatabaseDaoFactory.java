/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.apache.seatunnel.admin.init;

import org.apache.seatunnel.communal.DbType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import javax.sql.DataSource;
import java.util.HashMap;
import java.util.Map;

/**
 * Database DAO factory for plugin-based database support.
 * Similar to Apache DolphinScheduler's dao plugin pattern.
 */
@Configuration
public class DatabaseDaoFactory {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseDaoFactory.class);

    @Autowired
    private DataSource dataSource;

    /**
     * MySQL UpgradeDao bean activated when mysql profile is active.
     *
     * @return MySQLUpgradeDao instance
     */
    @Bean
    @Profile("mysql")
    public UpgradeDao mysqlUpgradeDao() {
        logger.info("Creating MySQL UpgradeDao");
        return new MySQLUpgradeDao(dataSource);
    }

    /**
     * H2 UpgradeDao bean activated when h2 profile is active.
     *
     * @return H2UpgradeDao instance
     */
    @Bean
    @Profile("h2")
    public UpgradeDao h2UpgradeDao() {
        logger.info("Creating H2 UpgradeDao");
        return new H2UpgradeDao(dataSource);
    }

    /**
     * Generic database DAO provider that returns the appropriate DAO based on database type.
     */
    @Bean
    public DatabaseDaoProvider databaseDaoProvider() {
        return new DatabaseDaoProvider();
    }

    /**
     * Database DAO provider that manages different database-specific DAO implementations.
     */
    public static class DatabaseDaoProvider {
        
        private final Map<DbType, UpgradeDao> daoMap = new HashMap<>();

        /**
         * Register a DAO implementation for a specific database type.
         *
         * @param dbType database type
         * @param upgradeDao DAO implementation
         */
        public void registerDao(DbType dbType, UpgradeDao upgradeDao) {
            daoMap.put(dbType, upgradeDao);
            logger.info("Registered DAO for database type: {}", dbType);
        }

        /**
         * Get DAO implementation for the specified database type.
         *
         * @param dbType database type
         * @return DAO implementation
         * @throws IllegalArgumentException if no DAO is registered for the database type
         */
        public UpgradeDao getDao(DbType dbType) {
            UpgradeDao dao = daoMap.get(dbType);
            if (dao == null) {
                throw new IllegalArgumentException("No DAO registered for database type: " + dbType);
            }
            return dao;
        }

        /**
         * Check if a DAO is registered for the specified database type.
         *
         * @param dbType database type
         * @return true if DAO is registered, false otherwise
         */
        public boolean isDaoRegistered(DbType dbType) {
            return daoMap.containsKey(dbType);
        }
    }
}