SELECT 
    a.emr_id AS 'EMR ID',
    a.ttr_start_date AS 'Treatment start date',
    a.days_on_ttr AS 'Days',
    (SELECT TRUNCATE(a.days_on_ttr / 30, 1)) AS 'Month',
    a.ttr_end_date AS 'Treatment end date',
    a.scd_date AS 'Sample collection date',
    /* (SELECT 
            name
        FROM
            concept_name
        WHERE
            concept_name.concept_id = a.samp_value_coded
                AND concept_name_type = 'SHORT'
                AND locale = 'en'
                AND concept_name.voided = 0) AS 'Type of sample', */
    a.s_col_id AS 'Sample ID',
    /* (SELECT 
            name
        FROM
            concept_name
        WHERE
            concept_name.concept_id = b.value_coded
                AND concept_name_type = 'SHORT'
                AND locale = 'en'
                AND concept_name.voided = 0) AS 'Smear result',
    */ (SELECT 
            name
        FROM
            concept_name
        WHERE
            concept_name.concept_id = c.value_coded
                AND concept_name_type = 'SHORT'
                AND locale = 'en'
                AND concept_name.voided = 0) AS 'Culture result',
    (SELECT 
            name
        FROM
            concept_name
        WHERE
            concept_name.concept_id = d.value_coded
                AND concept_name_type = 'SHORT'
                AND locale = 'en'
                AND concept_name.voided = 0) AS 'Consent obtained for isolate freezing/storing (Y/N)',
    (SELECT 
            name
        FROM
            concept_name
        WHERE
            concept_name.concept_id = e.value_coded
                AND concept_name_type = 'SHORT'
                AND locale = 'en'
                AND concept_name.voided = 0) AS 'Isolate frozen (Y/N)?'
FROM
    (SELECT 
        pi.patient_id AS patient_id,
            pi.identifier AS emr_id,
            DATE(ttr.obs_datetime) AS ttr_start_date,
            DATE(ttr_end.obs_datetime) AS ttr_end_date,
            DATE(scd.obs_datetime) AS scd_date,
            scd.encounter_id AS scd_encounter_id,
            scd.encounter_datetime AS scd_encounter_datetime,
            samp.value_coded AS samp_value_coded,
            sid.value_text AS s_col_id,
            DATEDIFF(scd.obs_datetime, ttr.obs_datetime) AS days_on_ttr
    FROM
        patient_identifier pi
    LEFT JOIN (SELECT 
        person_id, obs_datetime
    FROM
        obs
    WHERE
        concept_id = 1210 AND voided = 0) ttr ON pi.patient_id = ttr.person_id
    LEFT JOIN (SELECT 
        person_id, obs_datetime
    FROM
        obs
    WHERE
        concept_id = 1211 AND voided = 0) ttr_end ON pi.patient_id = ttr_end.person_id
    LEFT JOIN (SELECT 
        person_id,
            obs_datetime,
            obs_id,
            obs_group_id,
            obs.encounter_id,
            encounter_datetime
    FROM
        obs
    JOIN encounter e ON e.encounter_id = obs.encounter_id
        AND concept_id = 1188
        AND obs.voided = 0
        AND obs_group_id IN (SELECT 
            obs_id
        FROM
            obs
        WHERE
            concept_id = 1187 AND voided = 0)) scd ON pi.patient_id = scd.person_id
    LEFT JOIN (SELECT 
        person_id, value_coded, obs_group_id
    FROM
        obs
    WHERE
        concept_id = 1189 AND voided = 0
            AND obs_group_id IN (SELECT 
                obs_id
            FROM
                obs
            WHERE
                concept_id = 1187 AND voided = 0)) samp ON pi.patient_id = samp.person_id
        AND scd.obs_group_id = samp.obs_group_id
    LEFT JOIN (SELECT 
        person_id, value_text, obs_group_id
    FROM
        obs
    WHERE
        concept_id = 1190 AND voided = 0
            AND obs_group_id IN (SELECT 
                obs_id
            FROM
                obs
            WHERE
                concept_id = 1187 AND voided = 0)) id ON pi.patient_id = id.person_id
        AND scd.obs_group_id = id.obs_group_id
    LEFT JOIN (SELECT 
        person_id, value_text, obs_group_id, encounter_id
    FROM
        obs
    WHERE
        concept_id = 1190 AND voided = 0
            AND obs_group_id IN (SELECT 
                obs_id
            FROM
                obs
            WHERE
                concept_id = 1187 AND voided = 0)) sid ON pi.patient_id = sid.person_id
        AND scd.obs_group_id = sid.obs_group_id
        AND sid.encounter_id = scd.encounter_Id) a
       /* LEFT JOIN
    (SELECT 
        person_id,
            value_coded,
            obs_id,
            obs_group_id,
            obs_datetime,
            e.encounter_id,
            e.encounter_datetime
    FROM
        obs
    JOIN encounter e ON e.encounter_id = obs.encounter_id
        AND person_id = patient_id
        AND concept_id = 1093
        AND obs.voided = 0) b ON b.person_id = a.patient_id
        AND a.scd_encounter_id = b.encounter_id
        AND a.scd_encounter_datetime = b.encounter_datetime
        AND a.scd_date = b.obs_datetime
        */
        INNER JOIN
    (SELECT 
        person_id,
            value_coded,
            obs_id,
            obs_group_id,
            obs_datetime,
            obs.encounter_id,
            e.encounter_datetime
    FROM
        obs
    JOIN encounter e ON e.encounter_id = obs.encounter_id
        AND value_coded = 1134
        AND obs.voided = 0) c ON a.patient_id = c.person_id
		AND a.scd_date = c.obs_datetime
        AND a.scd_encounter_id = c.encounter_id
        AND a.scd_encounter_datetime = c.encounter_datetime
        -- AND a.days_on_ttr >= 0
        AND a.ttr_start_date BETWEEN '#startDate#' AND '#endDate#'
        LEFT JOIN
    (SELECT 
        person_id, value_coded
    FROM
        obs
    WHERE
        concept_id = 2986 AND voided = 0) d ON d.person_id = c.person_id
        LEFT JOIN
    (SELECT 
        person_id, value_coded, obs_datetime, obs_group_id
    FROM
        obs
    WHERE
        concept_id = 2987 AND voided = 0) e ON e.person_id = c.person_id
        AND a.scd_date = e.obs_datetime AND e.obs_group_id = c.obs_group_id
ORDER BY a.emr_id , a.scd_date;
