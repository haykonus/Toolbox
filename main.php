<?php

#-----------------------------------------------------------------------------
# main.php
#-----------------------------------------------------------------------------

define ("label",1);
define ("page", 2);

$TOP_MENU[10]  = array (label=>"", page=>"tm-home.html");
$TOP_MENU[20]  = array (label=>"Agents", page=>"");
$TOP_MENU[30]  = array (label=>"Monitors", page=>"tm-monitors.html");
$TOP_MENU[40]  = array (label=>"Hosts", page=>"");
$TOP_MENU[50]  = array (label=>"Maintenance", page=>"tm-dummy.html");
$TOP_MENU[60]  = array (label=>"Interfaces", page=>"tm-dummy.html");

$mainTemplate = "main.html";

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
switch ($menuId) {
	
		# Sub Menus
		case 21: # Agent statistics
			$container = file_get_contents("tm-agents-stat.html");
			break;
		case 22: # All agents
			$container = file_get_contents("tm-agents-list-all.html");
			break;	
			
		case 41: #
			$container = file_get_contents("tm-hosts-add-single.html");
			break;
		case 42: # 
			$container = file_get_contents("tm-hosts-add-from-list.html");
			break;					
			
		# other Menus	
		default:
			$container = file_get_contents($TOP_MENU[$menuId][page]);	
			
}	

$page = preg_replace("/###container###/", $container, $page);

# get and insert title
preg_match("/<h2>(.*)<\/h2>/", $container, $matches);
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
			$menu_html .= '<a class="dropdown-item" href="main.php?id=21">Agent statistics</a>';
			$menu_html .= '<a class="dropdown-item" href="main.php?id=22">All agents</a>';
			$menu_html .= '</div>';
			$menu_html .= '</li>';
		} else if ($menu_id == 40) {
			$menu_html .= '<li class="nav-item dropdown">';
			$menu_html .= '<a class="nav-link dropdown-toggle" href="" id="dropdown01" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">'.$menu[label].'</a>';
			$menu_html .= '<div class="dropdown-menu" aria-labelledby="dropdown01">';
			$menu_html .= '<a class="dropdown-item" href="main.php?id=41">Add single host</a>';
			$menu_html .= '<a class="dropdown-item" href="main.php?id=42">Add hosts from a list</a>';
			$menu_html .= '</div>';
			$menu_html .= '</li>';			
		} else {
			if ($current_menu_id == $menu_id) {
				$menu_html .= '<li class="nav-item active">';
				$menu_html .= '<a class="nav-link" href="main.php?id='.$menu_id.'">'.$menu[label].'<span class="sr-only">(current)</span> </a>';
				$menu_html .= '</li>';					
			} else {
				$menu_html .= '<li class="nav-item">';
				$menu_html .= '<a class="nav-link" href="main.php?id='.$menu_id.'">'.$menu[label].'</a>';
				$menu_html .= '</li>';			
			}
		}
	}			
	return $menu_html;			
}

?>
