SELECT 
    person_home_ownership AS Mənzil_Statusu,
    age_group AS Yaş_Qrupu,
    COUNT(*) AS Müştəri_Sayı,
    ROUND(AVG(loan_percent_income) * 100, 2) AS Gəlirə_Borc_Nisbəti_Pct,
    ROUND(AVG(loan_status) * 100, 2) AS Defolt_Faizi_Pct
FROM cleaned_credit_risk_dataset
GROUP BY person_home_ownership, age_group
ORDER BY person_home_ownership, Defolt_Faizi_Pct DESC;