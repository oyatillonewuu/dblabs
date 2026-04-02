
- T1.a

SELECT style_config
FROM tag_styles
WHERE
    app_type = 'WEB'
    AND
    user_role = 'admin';

- T1.b

SELECT style_config
FROM tag_styles
WHERE
    is_active
    AND
    tag_name = 'error_badge'
ORDER BY
    priority DESC;

- T1.c

SELECT tag_name
FROM tag_styles
WHERE
    (SELECT FROM JSON_CONTAINTS_PATH(style_config, "$.border-radius")) = 1;