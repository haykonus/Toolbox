//------------------------------------------------------------------------------------------
// Common globals
//------------------------------------------------------------------------------------------

TB_VERSION = "1.0.1";

var TOOLBOX_URL = 'http://svx-zabbixp001';
var UTILSCRIPTS = '/var/www/html/utilscripts';

//------------------------------------------------------------------------------------------
function rand() {
    return Math.floor(Math.random()*100);
}

//------------------------------------------------------------------------------------------
function getURL(url){
    return $.ajax({
        type: "GET",
        url: url,
        cache: false,
        async: false
    }).responseText;
}

//------------------------------------------------------------------------------------------
function showInfo() {
    
    document.getElementById('tagIdTbVersion').innerHTML = TB_VERSION;   
    $('#exampleModalCenter').modal();
}

//------------------------------------------------------------------------------------------
function infoTxtSuccess(tag, text) {
    document.getElementById(tag).innerHTML = text;
    document.getElementById(tag).setAttribute("class","text-success ml-2");
}

//------------------------------------------------------------------------------------------
function infoTxtDanger(tag, text) {
    document.getElementById(tag).innerHTML = text;
    document.getElementById(tag).setAttribute("class","text-danger ml-2");
}

//------------------------------------------------------------------------------------------
function infoTxtHide(tag) {
    document.getElementById(tag).innerHTML = '';
}

//------------------------------------------------------------------------------------------
function alertSuccess(text) {
    document.getElementById("tagIdAlert").innerHTML = text;
    document.getElementById("tagIdAlert").setAttribute("class","alert alert-success");
    document.getElementById("tagIdAlert").removeAttribute("hidden","");
}

//------------------------------------------------------------------------------------------
function alertDanger(text) {
    document.getElementById("tagIdAlert").innerHTML = text;
    document.getElementById("tagIdAlert").setAttribute("class","alert alert-danger");
    document.getElementById("tagIdAlert").removeAttribute("hidden","");
}

//------------------------------------------------------------------------------------------
function alertHide() {
    document.getElementById("tagIdAlert").setAttribute("hidden","");
}

