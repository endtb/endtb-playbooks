CREATE PROCEDURE bacteriology_culture_report()
BEGIN

CREATE TEMPORARY TABLE IF NOT EXISTS bacteriology_sample_id (personId INT(11), dates datetime, conceptId INT(11), obsGroupId INT(11), obsId INT(11), encounterId INT(11), valueText VARCHAR(255));
INSERT INTO bacteriology_sample_id(personId, dates, conceptId, obsGroupId, obsId, encounterId, valueText)
select person_id, obs_datetime, concept_id, obs_group_id, obs_id, encounter_id, value_text from obs o where o. obs_group_id IN (select obs_id from obs where concept_id = 1187 and voided = 0) and o.voided = 0 order by person_id;

    SET @startTbTreatment = 1210;
	SET @endTbTreatmentDate = 1211;
	SET @specimenSampleSource = 1189;
	SET @sputumSampleType = 1083;
	SET @specimenCollectionDate = 1188;
	SET @bacteriologyResults = 1192;
	SET @smearTestResults = 1181;
	SET @smearResult = 1093;
	SET @cultureResultDetails = 1176;
	SET @cultureResults = 1138;
	SET @mtbColonies = 1143;
    SET @specimenId = 1190;
    SET @bacteriologyConceptSet = 1187;

	SELECT  pi.identifier as 'EMR Id',
	s.person_id as PatientId,
	concat(n.given_name, ' ', n.family_name) as Name,
	(select DATE(MAX(startTr.value_datetime)) from obs startTr
		where startTr.person_id = s.person_id
			and startTr.concept_id = @startTbTreatment
			and startTr.voided = 0) as StartTreatmentDate,
	(select DATE(MAX(endTr.value_datetime)) from obs endTr
		where endTr.person_id = s.person_id
			and endTr.concept_id = @endTbTreatmentDate
			and endTr.voided = 0) as 'EndTreatmentDate',
	case when (o.value_coded is not null) then
			(
			select cn.name
			from concept c, concept_name cn
			where c.concept_id=cn.concept_id
				and c.concept_id=o.value_coded and cn.voided=0
				and cn.locale='en'
				and cn.concept_name_type = 'FULLY_SPECIFIED'
			)
		 else ifnull(o.value_coded, '')
	end as 'SampleType',
    valueText AS 'Sample Id',
	 DATE(odate.value_datetime) as SputumCollectionDate,
	( select DATEDIFF(SputumCollectionDate, StartTreatmentDate) as SIGNED) as TreatmentDays,
	( select getTreatMentMonth(CAST(DATEDIFF(SputumCollectionDate, StartTreatmentDate) as SIGNED))) as TreatmentMonth,
	(select GROUP_CONCAT(case when (smearResult.value_coded is not null) then
			(
			select cn.name
			from concept c, concept_name cn
			where c.concept_id=cn.concept_id
				and c.concept_id=smearResult.value_coded and cn.voided=0
				and cn.locale='en'
				and cn.concept_name_type = 'FULLY_SPECIFIED'
			)
		 else ifnull(smearResult.value_coded, '')
	end SEPARATOR ',') as 'SmearResult'
	from obs oin inner join obs smearTestResults on smearTestResults.obs_group_id = oin.obs_id
					and smearTestResults.voided = 0
					and smearTestResults.concept_id = @smearTestResults
				inner join obs smearResult
					ON smearResult.obs_group_id = smearTestResults.obs_id
					and smearResult.voided = 0
					and smearResult.concept_id = @smearResult
	where oin.voided = 0
		and oin.obs_group_id = o.obs_group_id
		and oin.concept_id = @bacteriologyResults) as SmearResults,
	(select GROUP_CONCAT(case when (cultureResult.value_coded is not null) then
			(
			select cn.name
			from concept c, concept_name cn
			where c.concept_id=cn.concept_id
				and c.concept_id=cultureResult.value_coded and cn.voided=0
				and cn.locale='en'
				and cn.concept_name_type = 'FULLY_SPECIFIED'
			)
		 else ifnull(cultureResult.value_coded, '')
	end SEPARATOR ',') as 'CultureResult'
	from obs ocr inner join obs cultureTestResults on cultureTestResults.obs_group_id = ocr.obs_id
					and cultureTestResults.voided = 0
					and cultureTestResults.concept_id = @cultureResultDetails
				inner join obs cultureResult
					ON cultureResult.obs_group_id = cultureTestResults.obs_id
					and cultureResult.voided = 0
					and cultureResult.concept_id = @cultureResults
	where ocr.voided = 0
		and ocr.obs_group_id = o.obs_group_id
		and ocr.concept_id = @bacteriologyResults) as CultureResults,

	(select GROUP_CONCAT(case when (cultureColonies.value_coded is not null) then
			(
			select cn.name
			from concept c, concept_name cn
			where c.concept_id=cn.concept_id
				and c.concept_id=cultureColonies.value_coded and cn.voided=0
				and cn.locale='en'
				and cn.concept_name_type = 'FULLY_SPECIFIED'
			)
		 else ifnull(cultureColonies.value_coded, '')
	end SEPARATOR ',') as 'MTBcolonies'
	from obs ocol inner join obs cultureTestResults on cultureTestResults.obs_group_id = ocol.obs_id
					and cultureTestResults.voided = 0
					and cultureTestResults.concept_id = @cultureResultDetails
				inner join obs cultureColonies
					ON cultureColonies.obs_group_id = cultureTestResults.obs_id
					and cultureColonies.voided = 0
					and cultureColonies.concept_id = @mtbColonies
	where ocol.voided = 0
		and ocol.obs_group_id = o.obs_group_id
		and ocol.concept_id = @bacteriologyResults) as MTBcolonies,
	e.encounter_id as encounterId,
	t.name as EncounterType,
	pn.name as ProgramName
	FROM person as s INNER JOIN
	(
		SELECT person_id, max(person_name_id), given_name, family_name
		FROM person_name where voided =0
		GROUP BY person_id
	) as n ON (s.person_id=n.person_id)
	INNER JOIN patient_identifier pi on pi.patient_id = s.person_id
	left outer join obs o on o.person_id = s.person_id
    left outer join bacteriology_sample_id on personId = s.person_id and conceptId = @specimenId and obsGroupId = o.obs_group_id
    inner join obs odate ON odate.obs_group_id = o.obs_group_id and odate.voided = 0 and odate.concept_id = @specimenCollectionDate
	inner join obs results ON results.obs_group_id  = o.obs_group_id and results.voided = 0 and results.concept_id = @bacteriologyResults
	inner join encounter e on e.encounter_id = o.encounter_id
	inner join encounter_type t on t.encounter_type_id = e.encounter_type
	inner join patient_program pp on pp.patient_id = s.person_id
	inner join program pn on pn.program_id = pp.program_id
	where  o.voided = 0
		and e.voided = 0
		and pp.voided = 0
		and pn.retired = 0
		 and o.concept_id = @specimenSampleSource
		 and o.value_coded = @sputumSampleType
	order by pi.identifier, TreatmentDays, PatientId, odate.value_datetime;

DROP TEMPORARY TABLE bacteriology_sample_id;
END