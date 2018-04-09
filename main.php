<?php

#-----------------------------------------------------------------------------
# main.php
#-----------------------------------------------------------------------------

define ("label",1);
define ("page", 2);

$TOP_MENU[10] = array (label=>"", page=>"tm-home.html");    
$TOP_MENU[20] = array (label=>"Agents", page=>"", 
                submenu=> array(
                    21 => array (label=>"Agent statistics", page=>"sm-agents-stat.html"),
                    22 => array (label=>"All agents", page=>"sm-agents-list-all.html")
                )); 
$TOP_MENU[30] = array (label=>"Monitors", page=>"tm-monitors.html");
$TOP_MENU[40] = array (label=>"Hosts", page=>"",
                submenu=> array(
                    41 => array (label=>"Add single host", page=>"sm-hosts-add-single.html"),
                    42 => array (label=>"Add hosts from file", page=>"sm-hosts-add-from-file.html")
                )); 
$TOP_MENU[50] = array (label=>"Maintenance", page=>"",
                submenu=> array(
                    51 => array (label=>"Close problems", page=>"sm-maintenance-close-problems.html")
                )); 

$TOP_MENU[60] = array (label=>"Interfaces", page=>"",
                submenu=> array(
                    61 => array (label=>"Show val import files", page=>"sm-interfaces-show-val-import-files.html"),
                    62 => array (label=>"Create val import files", page=>"sm-interfaces-create-val-import-files.html")
                )); 

$mainTemplate = "main.html";
$menuSid = 0;

# get the clicked menu id
if (isset($_GET['id'])) {
    $menuId = $_GET['id'];
    if (isset($_GET['sid'])) {
        $menuSid = $_GET['sid'];
    }   
}   
else {
    $menuId = "10"; # default is Home
}

# get the base template
$page = file_get_contents($mainTemplate);

# insert the menu 
$page = preg_replace("/###navigation###/", renderMenu ($menuId), $page);

# insert the container
if ($menuSid == 0) {
    print $TOP_MENU[menuId][page];
    $container = file_get_contents($TOP_MENU[$menuId][page]);
}
else {
    $container = file_get_contents($TOP_MENU[$menuId][submenu][$menuSid][page]);
}
$page = preg_replace("/###container###/", $container, $page);

# get and insert title
preg_match("/<h2>(.*)<\/h2>/", $container, $matches);
$pageTitle = strip_tags($matches[0]);
if (!$pageTitle) { 
    $pageTitle = "Zabbix Toolbox";
}
$page = preg_replace("/###title###/", $pageTitle, $page);

# show the page 
echo $page;

#-----------------------------------------------------------------------------
# renderMenu
#-----------------------------------------------------------------------------
function renderMenu($current_menu_id) {

    global $TOP_MENU;
    
    $menu_html = "";
        
    foreach ($TOP_MENU as $t => $topmenu) {
        if (count($topmenu[submenu]) == 0) {
            if ($current_menu_id == $t) {
                $menu_html .= '<li class="nav-item active">';
                $menu_html .= '<a class="nav-link" href="main.php?id='.$t.'">'.$topmenu[label].'<span class="sr-only">(current)</span> </a>';
                $menu_html .= '</li>';                  
            } else {
                $menu_html .= '<li class="nav-item">';
                $menu_html .= '<a class="nav-link" href="main.php?id='.$t.'">'.$topmenu[label].'</a>';
                $menu_html .= '</li>';          
            }               
        }
        else {  
            $menu_html .= '<li class="nav-item dropdown">';
            $menu_html .= '<a class="nav-link dropdown-toggle" href="" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">'.$topmenu[label].'</a>';
            $menu_html .= '<div class="dropdown-menu" >';
            foreach ($topmenu[submenu] as $s => $submenu) {
                $menu_html .= '<a class="dropdown-item" href="main.php?id='.$t.'&sid='.$s.'">'.$submenu[label].'</a>';
            }
            $menu_html .= '</div>';
            $menu_html .= '</li>';
        }
    }
        
    $menu_html .= '<li class="nav-item">';
    $menu_html .= '<a data-toggle="modal" class="nav-link" href="" onclick="showInfo()" >Info</a>';
    $menu_html .= '</li>';  
    
    return $menu_html;
}   

?>
