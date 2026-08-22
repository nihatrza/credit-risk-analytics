SELECT 
    loan_grade AS Risk_Dərəcəsi,
    COUNT(*) AS Müştəri_Sayı,
    ROUND(AVG(loan_int_rate), 2) AS Orta_Faiz_Dərəcəsi,
    ROUND(AVG(loan_amnt), 2) AS Orta_Kredit_Məbləği,
    ROUND(AVG(loan_status) * 100, 2) AS Faktiki_Defolt_Faizi_Pct
FROM cleaned_credit_risk_dataset
GROUP BY loan_grade
ORDER BY loan_grade ASC;