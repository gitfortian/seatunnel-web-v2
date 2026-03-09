-- H2 Database Initialization Script
-- Note: H2 syntax is compatible with MySQL mode

-- Create datasource table
CREATE TABLE IF NOT EXISTS t_seatunnel_datasource (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    db_name VARCHAR(64) DEFAULT NULL COMMENT 'Datasource name',
    db_type VARCHAR(64) DEFAULT NULL COMMENT 'Datasource type',
    original_json TEXT COMMENT 'Original JSON',
    connection_params TEXT COMMENT 'Database connection parameters',
    environment VARCHAR(200) DEFAULT NULL COMMENT 'Environment',
    remark VARCHAR(2048) DEFAULT NULL COMMENT 'Description',
    conn_status VARCHAR(24) DEFAULT NULL COMMENT 'Connection status',
    create_time TIMESTAMP DEFAULT NULL COMMENT 'Creation time',
    update_time TIMESTAMP DEFAULT NULL COMMENT 'Last update time'
);

-- Create datasource plugin config table
CREATE TABLE IF NOT EXISTS t_seatunnel_datasource_plugin_config (
    id VARCHAR(32) NOT NULL PRIMARY KEY COMMENT 'Primary key',
    plugin_type VARCHAR(50) NOT NULL COMMENT 'Plugin type: mysql, postgresql, oracle, etc',
    config_schema TEXT NOT NULL COMMENT 'Config schema in JSON format',
    create_time TIMESTAMP DEFAULT NULL COMMENT 'Creation time',
    update_time TIMESTAMP DEFAULT NULL COMMENT 'Last update time'
);

-- Create job definition table
CREATE TABLE IF NOT EXISTS t_seatunnel_job_definition (
    id BIGINT NOT NULL PRIMARY KEY COMMENT 'Primary key ID',
    job_name VARCHAR(255) NOT NULL COMMENT 'Job name',
    job_desc VARCHAR(500) DEFAULT NULL COMMENT 'Job description',
    job_definition_info LONGTEXT NOT NULL COMMENT 'Job definition info (JSON format)',
    job_version INT NOT NULL DEFAULT 1 COMMENT 'Job version',
    client_id BIGINT DEFAULT NULL COMMENT 'Client ID',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Update time',
    whole_sync BOOLEAN NOT NULL DEFAULT FALSE COMMENT 'Whether to perform a full data synchronization (1: full, 0: incremental)',
    source_type VARCHAR(255) DEFAULT NULL COMMENT 'Job source type (comma-separated)',
    sink_type VARCHAR(255) DEFAULT NULL COMMENT 'Job sink type (comma-separated)',
    parallelism INT DEFAULT 1 COMMENT 'Parallelism level of the job execution',
    source_table VARCHAR(1024) DEFAULT NULL COMMENT 'Job source table (comma-separated)',
    sink_table VARCHAR(1024) DEFAULT NULL COMMENT 'Job sink table (comma-separated)'
);

-- Create job instance table
CREATE TABLE IF NOT EXISTS t_seatunnel_job_instance (
    id BIGINT AUTO_INCREMENT PRIMARY KEY COMMENT 'Primary key ID',
    job_definition_id BIGINT NOT NULL COMMENT 'Job definition ID, foreign key to t_seatunnel_job_definition.id',
    job_config LONGTEXT COMMENT 'Job configuration',
    start_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation timestamp',
    end_time TIMESTAMP DEFAULT NULL COMMENT 'End timestamp',
    job_type VARCHAR(10) DEFAULT NULL COMMENT 'Job type: BATCH,STREAMING',
    job_status VARCHAR(255) DEFAULT NULL COMMENT 'Job status',
    job_engine_id VARCHAR(255) DEFAULT NULL COMMENT 'Job engine ID',
    log_path VARCHAR(512) DEFAULT NULL COMMENT 'Log file path',
    error_message LONGTEXT,
    run_mode VARCHAR(100) DEFAULT NULL
);

-- Create job metrics table
CREATE TABLE IF NOT EXISTS t_seatunnel_job_metrics (
    id BIGINT NOT NULL PRIMARY KEY COMMENT 'Primary key ID',
    job_instance_id BIGINT NOT NULL COMMENT 'Job instance ID',
    pipeline_id INT DEFAULT NULL COMMENT 'Pipeline ID',
    read_row_count BIGINT DEFAULT 0 COMMENT 'Read row count',
    write_row_count BIGINT DEFAULT 0 COMMENT 'Write row count',
    read_qps BIGINT DEFAULT 0 COMMENT 'Read QPS',
    write_qps BIGINT DEFAULT 0 COMMENT 'Write QPS',
    read_bytes BIGINT DEFAULT 0 COMMENT 'Read bytes',
    write_bytes BIGINT DEFAULT 0 COMMENT 'Write bytes',
    read_bps BIGINT DEFAULT 0 COMMENT 'Read BPS(bytes/second)',
    write_bps BIGINT DEFAULT 0 COMMENT 'Write BPS(bytes/second)',
    intermediate_queue_size BIGINT DEFAULT 0 COMMENT 'Intermediate queue size',
    lag_count BIGINT DEFAULT 0 COMMENT 'Lag count',
    loss_rate DOUBLE DEFAULT 0 COMMENT 'Loss rate',
    avg_row_size BIGINT DEFAULT 0 COMMENT 'Average row size(bytes)',
    record_delay BIGINT DEFAULT 0 COMMENT 'Record delay(ms)',
    create_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
    update_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP COMMENT 'Update time',
    job_definition_id BIGINT DEFAULT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS uk_instance_pipeline ON t_seatunnel_job_metrics(job_instance_id, pipeline_id);
CREATE INDEX IF NOT EXISTS idx_job_instance_id ON t_seatunnel_job_metrics(job_instance_id);
CREATE INDEX IF NOT EXISTS idx_create_time ON t_seatunnel_job_metrics(create_time);

-- Create job schedule table
CREATE TABLE IF NOT EXISTS t_seatunnel_job_schedule (
    id VARCHAR(32) NOT NULL PRIMARY KEY COMMENT 'Primary key',
    job_definition_id VARCHAR(32) NOT NULL COMMENT 'Job definition ID',
    cron_expression VARCHAR(50) NOT NULL COMMENT 'Cron expression',
    schedule_status VARCHAR(20) DEFAULT 'STOPPED' COMMENT 'Schedule status: STOPPED, RUNNING, PAUSED',
    last_schedule_time TIMESTAMP DEFAULT NULL COMMENT 'Last schedule time',
    next_schedule_time TIMESTAMP DEFAULT NULL COMMENT 'Next schedule time',
    schedule_config TEXT COMMENT 'Schedule configuration',
    create_time TIMESTAMP DEFAULT NULL COMMENT 'Creation time',
    update_time TIMESTAMP DEFAULT NULL COMMENT 'Last update time'
);

CREATE INDEX IF NOT EXISTS idx_task_definition_id ON t_seatunnel_job_schedule(job_definition_id);
CREATE INDEX IF NOT EXISTS idx_schedule_status ON t_seatunnel_job_schedule(schedule_status);

-- Create stream job definition table
CREATE TABLE IF NOT EXISTS t_seatunnel_stream_job_definition (
    id BIGINT NOT NULL PRIMARY KEY COMMENT 'Primary key ID',
    job_name VARCHAR(255) NOT NULL COMMENT 'Job name',
    job_desc VARCHAR(512) DEFAULT NULL COMMENT 'Job description',
    job_definition_info LONGTEXT COMMENT 'Stream job definition JSON/HOCON',
    job_type VARCHAR(50) NOT NULL COMMENT 'Job type (STREAM/BATCH)',
    job_version INT NOT NULL DEFAULT 1 COMMENT 'Job version',
    client_id BIGINT NOT NULL COMMENT 'Client ID',
    parallelism INT NOT NULL DEFAULT 1 COMMENT 'Parallelism level',
    schedule_status VARCHAR(50) DEFAULT 'OFFLINE' COMMENT 'Schedule status (ONLINE/OFFLINE/RUNNING/STOPPED)',
    source_type VARCHAR(100) DEFAULT NULL COMMENT 'Source type (mysql/kafka/etc)',
    source_table VARCHAR(255) DEFAULT NULL COMMENT 'Source table',
    sink_type VARCHAR(100) DEFAULT NULL COMMENT 'Sink type (mysql/hive/etc)',
    sink_table VARCHAR(255) DEFAULT NULL COMMENT 'Sink table',
    create_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Creation time',
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'Update time',
    plugin_name VARCHAR(100) DEFAULT NULL
);

CREATE INDEX IF NOT EXISTS idx_client_id ON t_seatunnel_stream_job_definition(client_id);
CREATE INDEX IF NOT EXISTS idx_job_name ON t_seatunnel_stream_job_definition(job_name);
CREATE INDEX IF NOT EXISTS idx_schedule_status ON t_seatunnel_stream_job_definition(schedule_status);

-- Create CDC server ID table
CREATE TABLE IF NOT EXISTS t_seatunnel_cdc_server_ids (
    server_id INT NOT NULL PRIMARY KEY,
    job_id VARCHAR(64) DEFAULT NULL,
    allocated_at TIMESTAMP DEFAULT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_job_jobid_server ON t_seatunnel_cdc_server_ids(job_id, server_id);

-- Create user table
CREATE TABLE IF NOT EXISTS t_seatunnel_user (
    id INT NOT NULL PRIMARY KEY COMMENT 'User ID',
    user_name VARCHAR(64) DEFAULT NULL COMMENT 'Username',
    user_password VARCHAR(64) DEFAULT NULL COMMENT 'User password',
    user_type INT DEFAULT NULL COMMENT 'User type',
    email VARCHAR(64) DEFAULT NULL COMMENT 'Email address',
    phone VARCHAR(11) DEFAULT NULL COMMENT 'Phone number',
    create_time TIMESTAMP DEFAULT NULL COMMENT 'Creation time',
    update_time TIMESTAMP DEFAULT NULL COMMENT 'Last update time',
    state TINYINT DEFAULT 1 COMMENT 'State: 0=disabled, 1=enabled'
);

INSERT INTO t_seatunnel_user
(id, user_name, user_password, user_type, email, phone, create_time, update_time, state)
VALUES
(1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 0, '295227940@qq.com', '15002344940', NOW(), NOW(), 1);

-- Create session table
CREATE TABLE IF NOT EXISTS t_seatunnel_session (
    id VARCHAR(64) NOT NULL PRIMARY KEY COMMENT 'Session ID',
    user_id INT DEFAULT NULL COMMENT 'Associated user ID',
    ip VARCHAR(45) DEFAULT NULL COMMENT 'Client IP address',
    last_login_time TIMESTAMP DEFAULT NULL COMMENT 'Last login timestamp'
);

-- ==================== Quartz Scheduler Tables ====================

-- Blob Triggers
CREATE TABLE IF NOT EXISTS QRTZ_BLOB_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    blob_data BLOB,
    PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

-- Calendars
CREATE TABLE IF NOT EXISTS QRTZ_CALENDARS (
    sched_name VARCHAR(120) NOT NULL,
    calendar_name VARCHAR(200) NOT NULL,
    calendar BLOB NOT NULL,
    PRIMARY KEY (sched_name, calendar_name)
);

-- Cron Triggers
CREATE TABLE IF NOT EXISTS QRTZ_CRON_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    cron_expression VARCHAR(200) NOT NULL,
    time_zone_id VARCHAR(80),
    PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

-- Fired Triggers
CREATE TABLE IF NOT EXISTS QRTZ_FIRED_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    entry_id VARCHAR(95) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    fired_time BIGINT NOT NULL,
    sched_time BIGINT NOT NULL,
    priority INTEGER NOT NULL,
    state VARCHAR(16) NOT NULL,
    job_name VARCHAR(200),
    job_group VARCHAR(200),
    is_nonconcurrent VARCHAR(1),
    requests_recovery VARCHAR(1),
    PRIMARY KEY (sched_name, entry_id)
);

-- Job Details
CREATE TABLE IF NOT EXISTS QRTZ_JOB_DETAILS (
    sched_name VARCHAR(120) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    job_class_name VARCHAR(250) NOT NULL,
    is_durable VARCHAR(1) NOT NULL,
    is_nonconcurrent VARCHAR(1) NOT NULL,
    is_update_data VARCHAR(1) NOT NULL,
    requests_recovery VARCHAR(1) NOT NULL,
    job_data BLOB,
    PRIMARY KEY (sched_name, job_name, job_group)
);

-- Locks
CREATE TABLE IF NOT EXISTS QRTZ_LOCKS (
    sched_name VARCHAR(120) NOT NULL,
    lock_name VARCHAR(40) NOT NULL,
    PRIMARY KEY (sched_name, lock_name)
);

-- Paused Trigger Groups
CREATE TABLE IF NOT EXISTS QRTZ_PAUSED_TRIGGER_GRPS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    PRIMARY KEY (sched_name, trigger_group)
);

-- Scheduler State
CREATE TABLE IF NOT EXISTS QRTZ_SCHEDULER_STATE (
    sched_name VARCHAR(120) NOT NULL,
    instance_name VARCHAR(200) NOT NULL,
    last_checkin_time BIGINT NOT NULL,
    checkin_interval BIGINT NOT NULL,
    PRIMARY KEY (sched_name, instance_name)
);

-- Simple Triggers
CREATE TABLE IF NOT EXISTS QRTZ_SIMPLE_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    repeat_count BIGINT NOT NULL,
    repeat_interval BIGINT NOT NULL,
    times_triggered BIGINT NOT NULL,
    PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

-- Simprop Triggers
CREATE TABLE IF NOT EXISTS QRTZ_SIMPROP_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    str_prop_1 VARCHAR(512),
    str_prop_2 VARCHAR(512),
    str_prop_3 VARCHAR(512),
    int_prop_1 INTEGER,
    int_prop_2 INTEGER,
    long_prop_1 BIGINT,
    long_prop_2 BIGINT,
    dec_prop_1 DECIMAL(13,4),
    dec_prop_2 DECIMAL(13,4),
    bool_prop_1 VARCHAR(1),
    bool_prop_2 VARCHAR(1),
    PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

-- Triggers
CREATE TABLE IF NOT EXISTS QRTZ_TRIGGERS (
    sched_name VARCHAR(120) NOT NULL,
    trigger_name VARCHAR(200) NOT NULL,
    trigger_group VARCHAR(200) NOT NULL,
    job_name VARCHAR(200) NOT NULL,
    job_group VARCHAR(200) NOT NULL,
    description VARCHAR(250),
    next_fire_time BIGINT,
    prev_fire_time BIGINT,
    priority INTEGER,
    trigger_state VARCHAR(16) NOT NULL,
    trigger_type VARCHAR(8) NOT NULL,
    start_time BIGINT NOT NULL,
    end_time BIGINT,
    calendar_name VARCHAR(200),
    misfire_instr SMALLINT,
    job_data BLOB,
    PRIMARY KEY (sched_name, trigger_name, trigger_group)
);

-- Create foreign key constraints
ALTER TABLE QRTZ_TRIGGERS ADD CONSTRAINT FK_QRTZ_TRIGGERS_1 FOREIGN KEY (sched_name, job_name, job_group) REFERENCES QRTZ_JOB_DETAILS(sched_name, job_name, job_group);
ALTER TABLE QRTZ_BLOB_TRIGGERS ADD CONSTRAINT FK_QRTZ_BLOB_TRIGGERS_1 FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group);
ALTER TABLE QRTZ_CRON_TRIGGERS ADD CONSTRAINT FK_QRTZ_CRON_TRIGGERS_1 FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group);
ALTER TABLE QRTZ_SIMPLE_TRIGGERS ADD CONSTRAINT FK_QRTZ_SIMPLE_TRIGGERS_1 FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group);
ALTER TABLE QRTZ_SIMPROP_TRIGGERS ADD CONSTRAINT FK_QRTZ_SIMPROP_TRIGGERS_1 FOREIGN KEY (sched_name, trigger_name, trigger_group) REFERENCES QRTZ_TRIGGERS(sched_name, trigger_name, trigger_group);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_qrtz_j_req_recovery ON QRTZ_JOB_DETAILS(sched_name, requests_recovery);
CREATE INDEX IF NOT EXISTS idx_qrtz_t_next_fire_time ON QRTZ_TRIGGERS(sched_name, next_fire_time);
CREATE INDEX IF NOT EXISTS idx_qrtz_t_state ON QRTZ_TRIGGERS(sched_name, trigger_state);
CREATE INDEX IF NOT EXISTS idx_qrtz_t_nft_st ON QRTZ_TRIGGERS(sched_name, next_fire_time, trigger_state);
CREATE INDEX IF NOT EXISTS idx_qrtz_ft_inst_name ON QRTZ_FIRED_TRIGGERS(sched_name, instance_name);
CREATE INDEX IF NOT EXISTS idx_qrtz_ft_inst_job_req_rcvry ON QRTZ_FIRED_TRIGGERS(sched_name, instance_name, requests_recovery);
CREATE INDEX IF NOT EXISTS idx_qrtz_ft_j_g ON QRTZ_FIRED_TRIGGERS(sched_name, job_name, job_group);
CREATE INDEX IF NOT EXISTS idx_qrtz_ft_jg ON QRTZ_FIRED_TRIGGERS(sched_name, job_group);
CREATE INDEX IF NOT EXISTS idx_qrtz_ft_t_g ON QRTZ_FIRED_TRIGGERS(sched_name, trigger_name, trigger_group);
CREATE INDEX IF NOT EXISTS idx_qrtz_ft_tg ON QRTZ_FIRED_TRIGGERS(sched_name, trigger_group);
