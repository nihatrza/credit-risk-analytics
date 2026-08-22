SELECT 
    loan_intent AS Kredit_Məqsədi,
    COUNT(*) AS Müraciət_Sayı,
    ROUND(SUM(loan_amnt), 2) AS Toplam_Məbləğ,
    ROUND(AVG(loan_int_rate), 2) AS Orta_Faiz,
    ROUND(AVG(loan_status) * 100, 2) AS Defolt_Faizi_Pct
FROM cleaned_credit_risk_dataset
GROUP BY loan_intent
ORDER BY Defolt_Faizi_Pct DESC;