<?php
#-----------------------------------------------------------------------------
# main.php
#-----------------------------------------------------------------------------

define ("label",1);
define ("page", 2);

$TOP_MENU[10]  = array (label=>"", page=>"home.html");
$TOP_MENU[20]  = array (label=>"Agents", page=>"");
$TOP_MENU[30]  = array (label=>"Monitors", page=>"dummy.html");
$TOP_MENU[40]  = array (label=>"Hosts", page=>"dummy.html");
$TOP_MENU[50]  = array (label=>"Maintenance", page=>"dummy.html");
$TOP_MENU[60]  = array (label=>"Interfaces", page=>"dummy.html");


$mainTemplate = "main-php.html";

# get the clicked menu id
if(isset($_GET['id'])) {
	$menuId = $_GET['id'];
}	
else {
	$menuId = "10"; # default is Home
}
# get the base template
$page = file_get_contents($mainTemplate);

# insert the menu 
$page = preg_replace("/###navigation###/", renderMenu ($menuId), $page);

# insert the page content
$content = file_get_contents($TOP_MENU[$menuId][page]);

switch ($menuId) {
	
		case 21: # Agent statistics
			$content = agentVersions();
			break;
			
		case 22: # All agents
			$content = agentListAll();
			break;		
		
		case 30: # Monitors
			break;
		
		default:
			
}	

$page = preg_replace("/###content###/", $content, $page);

# get and insert title
preg_match("/<h2>(.*)<\/h2>/", $content, $matches);
$pageTitle = strip_tags($matches[0]);
if (!$pageTitle) { $pageTitle = "Zabbix Toolbox";}
$page = preg_replace("/###title###/", $pageTitle, $page);

# show the page 
echo $page;

#-----------------------------------------------------------------------------
# renderMenu
#-----------------------------------------------------------------------------
function renderMenu($current_menu_id) {

	global $TOP_MENU;
	
	$menu_html = "";
	
	foreach ($TOP_MENU as $menu_id => $menu) {
	
		if ($menu_id == 20) {
			$menu_html .= '<li class="nav-item dropdown">';
			$menu_html .= '<a class="nav-link dropdown-toggle" href="" id="dropdown01" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">'.$menu[label].'</a>';
			$menu_html .= '<div class="dropdown-menu" aria-labelledby="dropdown01">';
			$menu_html .= '<a class="dropdown-item" href="main-php.php?id=21">Agent statistics</a>';
			$menu_html .= '<a class="dropdown-item" href="main-php.php?id=22">All agents</a>';
			$menu_html .= '</div>';
			$menu_html .= '</li>';
		} else {
			if ($current_menu_id == $menu_id) {
				$menu_html .= '<li class="nav-item active">';
				$menu_html .= '<a class="nav-link" href="main-php.php?id='.$menu_id.'">'.$menu[label].'<span class="sr-only">(current)</span> </a>';
				$menu_html .= '</li>';					
			} else {
				$menu_html .= '<li class="nav-item">';
				$menu_html .= '<a class="nav-link" href="main-php.php?id='.$menu_id.'">'.$menu[label].'</a>';
				$menu_html .= '</li>';			
			}
		}
	}			
	return $menu_html;			
}

#-----------------------------------------------------------------------------
# Agent versions
#-----------------------------------------------------------------------------

function agentVersions () {

	# get the statistcs as JSON string	
	
	$json = exec ("/bin/perl /var/www/html/perl/zbx_agent_versions.pl");	
	$agents = (json_decode($json, TRUE));

	# build the agent list
	
	$aList = '
	<table class="table table-striped">
	<thead>
		<tr>
		<th scope="col">version</th>
		<th scope="col"># installed</th>
    </tr>
	</thead>
	<tbody>
	';
	
	krsort ($agents);	
	foreach ($agents as $version => $number) {
		$aList .= '<tr>';
		$aList .= '<td>'.$version.'</td>'.'<td>'.$number.'</td>';
		$aList .= '</tr>';
	}
	$aList .= '
	</tbody>
	</table>
	';
	
	# build the chart parameter "label" and "data"
	
	$v = '['; $n = '['; $first=1; $count=0;
	arsort ($agents);
	foreach ($agents as $version => $number) {
		if (!$first){$v.=',';$n.=',';};$first=0;
		$v .= '"'.$version.'"';
		$n .= $number;
		$count++;
		if ($count >= 5) break;
	}
	$v .= ']'; $n .= ']';
		
		
	# content template
	
    $c = '
	<h2> Agent statistics</h2>
	<div class="base">
		<div class="row">
			<div class="col">
				
				
				###AGENT_LIST###
			
			</div>
			<div class="col">
				
				<h5 class="card-title text-center">TOP 5 agents</h5>
				<canvas id="doughnutChart"></canvas>
				
			</div>
		</div>
		<hr>
	</div>
		
	<script>
		var ctxD = document.getElementById("doughnutChart").getContext(\'2d\');
		var myLineChart = new Chart(ctxD, {
			type: \'doughnut\',
			data: {
				labels:  '.$v.'  ,
				datasets: [
					{
						data: '.$n.' ,
						backgroundColor: ["#F7464A", "#46BFBD", "#FDB45C", "#949FB1", "#4D5360"],
						hoverBackgroundColor: ["#FF5A5E", "#5AD3D1", "#FFC870", "#A8B3C5", "#616774"]
					}
				]
			},
			options: {
				responsive: true
			}    
		});
	</script>
	';
	
	$c = preg_replace("/###AGENT_LIST###/", $aList, $c);
	
	return $c;		
}

#-----------------------------------------------------------------------------
# Agent list all
#-----------------------------------------------------------------------------

function agentListAll () {

	$c  = '<h2> Coming soon ...</h2>';
	$c .= '<p>';
	#$c .= exec ("/usr/bin/perl /var/www/html/perl/zbx_agent_versions.pl");
	$c .= '</p>';
	return $c;		
}

?>
