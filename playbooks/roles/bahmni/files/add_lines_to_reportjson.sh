#!/usr/bin/env bash

echo '},' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo " "  >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo '  "CultureResults": { ' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo '     "name": "Culture Results (Excel)", ' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo '     "type": "MRSGeneric", ' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo '     "config": { ' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo '     "sqlPath": "/var/www/bahmni_config/openmrs/apps/reports/sql/cultureResults.sql", ' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo '     "macroTemplatePath" : "/var/www/bahmni_config/openmrs/apps/reports/macroTemplates/Empty.xls" ' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo '   } ' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo '  } ' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo " " >> /var/www/bahmni_config/openmrs/apps/reports/reports.json
echo '} ' >> /var/www/bahmni_config/openmrs/apps/reports/reports.json