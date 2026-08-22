SELECT 
    COUNT(*) AS Toplam_Müştəri,
    ROUND(SUM(loan_amnt), 2) AS Toplam_Kredit_Məbləği,
    ROUND(SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END), 2) AS Riskdə_Olan_Məbləğ,
    ROUND(AVG(loan_status) * 100, 2) AS Defolt_Faizi_Pct,
    ROUND(AVG(loan_int_rate), 2) AS Orta_Faiz_Dərəcəsi
FROM cleaned_credit_risk_dataset;