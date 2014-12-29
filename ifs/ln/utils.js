if(!window.console)console={log:function(){}};String.prototype.trim=function(){a=this.replace(/^\s+/,'');return a.replace(/\s+$/,'');};function newAjaxRequest(){var xmlhttp=null;if(window.XMLHttpRequest){xmlhttp=new XMLHttpRequest();if(xmlhttp.overrideMimeType){xmlhttp.overrideMimeType('text/xml');}}else if(window.ActiveXObject){try{xmlhttp=new ActiveXObject("Msxml2.XMLHTTP");}catch(e){try{xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");}catch(e){}}}
return xmlhttp;}
function getProps(obj){var propList='';for(var props in obj){propList+=(props+"="+ obj[props]+" ");}
return propList;}
function dumpProps(obj){alert(getProps(obj));}
function propNames(obj){var propList='';for(var props in obj){propList+=(props+" ");}
return propList;}
function dumpPropNames(obj){alert(propNames(obj));}
function getScrollBarWidth(){return 18;}
function getCellPadding(){return 4;}
function findPos(obj){var curleft=curtop=0;if(obj.offsetParent){do{curleft+=obj.offsetLeft;curtop+=obj.offsetTop;}while(obj=obj.offsetParent);}
return{x:curleft,y:curtop};}
function getCssRule(selectorText){for(var s=0;s<document.styleSheets.length;s++){var theRules;if(document.styleSheets[s].cssRules){theRules=document.styleSheets[s].cssRules;}else if(document.styleSheets[s].rules){theRules=document.styleSheets[s].rules;}
else{continue;}
for(var r=0;r<theRules.length;r++){var rule=theRules[r];if(rule.selectorText==selectorText){return rule;}}
selectorText=selectorText.toLowerCase();for(var r=0;r<theRules.length;r++){var rule=theRules[r];if(rule.selectorText.toLowerCase()==selectorText){return rule;}}}
alert('did not find rule named '+ selectorText);return null;}
var ENTER_KEY=13;var SHIFT_KEY=16;var SPACEBAR_KEY=32;var LEFT_ARROW_KEY=37;var UP_ARROW_KEY=38;var RIGHT_ARROW_KEY=39;var DOWN_ARROW_KEY=40;var C_KEY=67;var H_KEY=72;var I_KEY=73;var J_KEY=74;var K_KEY=75;var L_KEY=76;var R_KEY=82;var W_KEY=87;var SEMICOLON_KEY=186;function keyCode(event){if(window.event){return event.keyCode;}
else if(event.which){return event.which;}
return 0;}
function randomInteger(min,max){return Math.floor(Math.random()*(max-min))+ min;}
function getSelectedValue(selectObj){return selectObj.options[selectObj.selectedIndex].value;}
function setSelectedValue(selectObj,value){for(var i=0;i<selectObj.options.length;i++){if(selectObj.options[i].value==value){selectObj.selectedIndex=i;return;}}
alert('value '+ value+' not found.');}
function sendAjaxHighScoreMessage(studyStackId,gameId,score){var xmlhttp=newAjaxRequest();xmlhttp.onreadystatechange=function(){if(xmlhttp.readyState==4){try{var highScoreContent=xmlhttp.responseText;document.getElementById('highScoreContainer').innerHTML=highScoreContent;document.getElementById('highScoreFrame').style.display='inline';}
catch(err){}}}
var url='highScores.jsp?studyStackId='+ studyStackId+'&gameId='+ gameId+'&score='+ score;xmlhttp.open('GET',url,true);xmlhttp.send('text=123');}
var lastKeepAliveTime=0;function sendKeepAlive(){var now=new Date().getTime();if(now- lastKeepAliveTime>60*1000){var xmlhttp=newAjaxRequest();var url='keepAlive.jsp';xmlhttp.open('GET',url,true);xmlhttp.send('1');lastKeepAliveTime=now;}}
function sendAjaxSaveSessionMessage(studyStackId,sessionData){var xmlhttp=newAjaxRequest();var url='saveSessionState.jsp';var params='studyStackId='+ studyStackId+'&sessionData='+ sessionData;xmlhttp.open('POST',url,false);xmlhttp.setRequestHeader("Content-type","application/x-www-form-urlencoded");xmlhttp.send(params);}
function facebook_onlogin(){window.location.href='fbConnector.jsp';}
function showLabel(obj){if(obj&&obj.value.length==0){var labelObj=document.getElementById(obj.id+"Label");if(labelObj){labelObj.style.display="inline";}}}
function hideLabel(obj){if(obj){var labelObj=document.getElementById(obj.id+"Label");if(labelObj){labelObj.style.display="none";}}}
function enableObject(obj,enable){if(obj){obj.disabled=!enable;}}
var uniqueStatus;function checkUniqueValue(value,table,column,originalValue,buttonObj){uniqueStatus=document.getElementById("uniqueStatus");if(value==originalValue){uniqueStatus.innerHTML='';enableObject(buttonObj,true);return;}
if(value==''){showUniqueStatus(uniqueStatus,false,buttonObj);return;}
uniqueStatus.innerHTML="<img src='images/spinner.gif' alt='checking'/>";var xmlhttp=newAjaxRequest();xmlhttp.onreadystatechange=function(){if(xmlhttp.readyState==4){try{var count=xmlhttp.responseText;showUniqueStatus(uniqueStatus,count<=0,buttonObj);}
catch(err){}}}
var url="countRecords.jsp"+"?table="+ table+"&column="+ column+"&value="+ escape(value);xmlhttp.open('GET',url,true);xmlhttp.send('text=text');}
function showUniqueStatus(obj,available,buttonObj){if(!available){obj.innerHTML="taken";obj.style.color='#dd2222';}
else{obj.innerHTML="available";obj.style.color='#669900';}
enableObject(buttonObj,available);}
function deindexSet(studyStackId,successFunc){var xmlhttp=newAjaxRequest();xmlhttp.onreadystatechange=function(){if(xmlhttp.readyState==4){try{var response=xmlhttp.responseText;if(parseInt(response.trim())==1){successFunc();}}
catch(err){}}}
var url='DeindexStack.jsp?studyStackId='+ studyStackId;xmlhttp.open('GET',url,true);xmlhttp.send('text=123');}
function deleteScores(studyStackId,gameId){var xmlhttp=newAjaxRequest();xmlhttp.onreadystatechange=function(){if(xmlhttp.readyState==4){try{var highScoreContent=xmlhttp.responseText;document.getElementById('highScoreContainer').innerHTML='';document.getElementById('highScoreFrame').style.display='inline';}
catch(err){}}}
var url='deleteHighScores.jsp?studyStackId='+ studyStackId+'&gameId='+ gameId;xmlhttp.open('GET',url,true);xmlhttp.send('text=123');}
function hide(obj){if(obj!=null){obj.style.display='none';}}
function debug(message){}
function createCookie(name,value,days){if(days){var date=new Date();date.setTime(date.getTime()+(days*24*60*60*1000));var expires="; expires="+date.toGMTString();}
else var expires="";document.cookie=name+"="+value+expires+"; path=/";}
function readCookie(name){var nameEQ=name+"=";var ca=document.cookie.split(';');for(var i=0;i<ca.length;i++){var c=ca[i];while(c.charAt(0)==' ')c=c.substring(1,c.length);if(c.indexOf(nameEQ)==0)return c.substring(nameEQ.length,c.length);}
return null;}
function eraseCookie(name){createCookie(name,"",-1);}
function removeUrlParameter(url,paramName){var start=url.indexOf('&'+ paramName+'=');if(start<0){start=url.indexOf('?'+ paramName+'=');if(start<0){return url;}}
var end=url.indexOf('&',start+ 1);if(end>0){url=url.substr(0,start)+ url.substr(end);}
else{url=url.substr(0,start);}
if(url.indexOf('?')<0&&url.indexOf('&')==start){url=url.substr(0,start)+'?'+ url.substr(start+ 1);}
return url;}
function addUrlParameter(url,paramName,paramValue){if(url.indexOf('?')<0){url=url+'?'+ paramName+'='+ paramValue;}
else{url=url+'&'+ paramName+'='+ paramValue;}
return url;}
function setUrlParameter(url,paramName,paramValue){var start=url.indexOf('&'+ paramName+'=');if(start<0){start=url.indexOf('?'+ paramName+'=');}
var end=url.indexOf('&',start+1);if(start<0||end<0){return addUrlParameter(removeUrlParameter(url,paramName),paramName,paramValue);}
return url.substr(0,start+ paramName.length+ 2)+ paramValue+ url.substr(end);}
function uiEventForAdFlips(){if(typeof(flipAdsPeriodically)==typeof(Function)){flipAdsPeriodically();}}
