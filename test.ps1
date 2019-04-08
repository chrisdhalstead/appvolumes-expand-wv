
$response = Invoke-RestMethod -uri 'https://s1-avm1.vmweuc.com/cv_api/sessions' -SessionVariable $ssession -Method Post -Body $json -ContentType 'application/json'

$response