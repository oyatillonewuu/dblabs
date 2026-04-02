CREATE TABLE tag_styles (
    id          INT AUTO_INCREMENT,
    tag_name    VARCHAR(50) NOT NULL,
    app_type    VARCHAR(20) NOT NULL, 
    user_role   VARCHAR(30),
    style_config JSON NOT NULL,
    is_active   BOOLEAN DEFAULT TRUE,
    priority    INT DEFAULT 0,
    PRIMARY KEY (id)
);