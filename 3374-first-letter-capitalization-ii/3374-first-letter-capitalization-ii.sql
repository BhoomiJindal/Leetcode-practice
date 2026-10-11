
WITH RECURSIVE chars AS (
    SELECT
        content_id,
        content_text AS txt,
        1 AS pos,
        SUBSTRING(content_text, 1, 1) AS ch,
        1 AS word_idx
    FROM user_content

    UNION ALL

    SELECT
        content_id,
        txt,
        pos + 1,
        SUBSTRING(txt, pos + 1, 1),
        word_idx + CASE WHEN ch = ' ' THEN 1 ELSE 0 END
    FROM chars
    WHERE pos < CHAR_LENGTH(txt)
),
annotated AS (
    SELECT
        c.*,
        SUBSTRING_INDEX(
            SUBSTRING_INDEX(txt, ' ', word_idx),
            ' ',
            -1
        ) AS word
    FROM chars c
),
converted AS (
    SELECT
        content_id,
        txt,
        pos,
        CASE
            WHEN ch = ' ' THEN ' '

            -- Leave the entire word unchanged if it starts
            -- with a non-English letter
            WHEN LOCATE(
                LEFT(word, 1),
                'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
            ) = 0
            THEN ch

            -- Capitalize every part of a valid hyphenated word
            WHEN word REGEXP '^[A-Za-z]+(-[A-Za-z]+)+$'
            THEN
                CASE
                    WHEN pos = 1
                      OR SUBSTRING(txt, pos - 1, 1) IN (' ', '-')
                    THEN UPPER(ch)
                    ELSE LOWER(ch)
                END

            -- Ordinary word: capitalize only its first letter
            WHEN pos = 1
              OR SUBSTRING(txt, pos - 1, 1) = ' '
            THEN UPPER(ch)

            ELSE LOWER(ch)
        END AS converted_char
    FROM annotated
)
SELECT
    content_id,
    MAX(txt) AS original_text,
    GROUP_CONCAT(
        converted_char ORDER BY pos SEPARATOR ''
    ) AS converted_text
FROM converted
GROUP BY content_id
ORDER BY content_id;
