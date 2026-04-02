
-- T1.a

SELECT style_config
FROM tag_styles
WHERE
    app_type = 'WEB'
    AND
    user_role = 'admin';

-- T1.b

SELECT style_config
FROM tag_styles
WHERE
    is_active
    AND
    tag_name = 'error_badge'
ORDER BY
    priority DESC;

-- T1.c

SELECT *
FROM tag_styles
WHERE
    JSON_CONTAINS_PATH(
        style_config,
        'all',
        '$.borderRadius'
    ) = 1;

-- T1.d

SELECT
    style_config->>'$.background' AS background_color,
    style_config->>'$.background' AS padding
FROM
    tag_styles
WHERE
    tag_name = 'submit_button'
    AND
    app_type = 'mobile'
    AND
    user_role = 'viewer';

-- T1.e

UPDATE
    tag_styles
SET
    style_config = JSON_SET(style_config, '$.hover.transform', 'scale(1.02)')
WHERE
    tag_name = 'submit_button'
    AND
    app_type = 'web'
    AND
    user_role = 'admin';
