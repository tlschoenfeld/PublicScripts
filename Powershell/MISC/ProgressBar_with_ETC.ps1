# Data Source
$Information = 1..1000000

# Initialize Tracking
$start = Get-Date
$i = 0
$total = $Information.Count

# Loop
foreach ($piece in $information) {
	# Progress Tracking
	$i++
	$prct = [Math]::Round((($i / $total) * 100.0), 2)

	$elapsed = (Get-Date) - $start
	$totalTime = ($elapsed.TotalSeconds) / ($prct / 100.0)
	$remain = $totalTime - $elapsed.TotalSeconds
	$eta = (Get-Date).AddSeconds($remain)
	
	# Display
	Write-Progress -Activity "What is going on (ETC $eta)" -Status "$prct %" -PercentComplete $prct
	
	# Operation

}