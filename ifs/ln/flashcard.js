var cardIndexes;var currentCard;var currentSide;var frontSide;var backSide;var remainingCards;var incorrectCards;var correctCards;var pauseButton;var infoCard;var infoCardContent;var currentCardIndex=-1;var reverseOrderCheckBox;var usedSpaceBar=false;var usedUpOrDownKeys=false;var usedUndo=false;var usedRetry=false;var usedPause=false;var clickToFlipColor=185;$(document).ready(function(){startOver();});$(window).unload(function(event){if(logonId!=''){saveBoxStates();}});var paused=false;var blurTimer=null;var gameFocus=true;var retries=0;var MOVE_TO_CORRECT=1;var MOVE_TO_INCORRECT=2;var MOVE_TO_REMAINING=3;var RETRY=4;var START_OVER=5;var TOGGLE_PAUSE=6;var FLIP_CARD=7;var UNDO_MOVE=8;var SHUFFLE=9;var UNDO_CORRECT=10;var UNDO_INCORRECT=11;var CLOSE_HELP=12;var SHOW_HELP=13;var TOGGLE_AUTO_PLAY=14;var SET_AUTO_SPEED=15;var noActionsUntil=0;var autoSpeedX=0;function createInitialOrderArray(size){var orderArray=new Array();var i;for(i=0;i<size;i++){orderArray[i]=size-i-1;}
return orderArray;}
function doAction(command){if(command!=TOGGLE_PAUSE){continueTimer();}
if(infoCard.css('display')!='none'){infoCard.hide();continueTimer();return;}
var now=new Date().getTime();var delay=500;if(now<noActionsUntil){return;}
switch(command){case MOVE_TO_CORRECT:moveCurrentToCorrect();break;case MOVE_TO_INCORRECT:moveCurrentToIncorrect();break;case MOVE_TO_REMAINING:moveCurrentToRemaining();break;case RETRY:retry();break;case START_OVER:startOver();break;case TOGGLE_PAUSE:togglePause();break;case FLIP_CARD:flipCard();delay=100;break;case UNDO_MOVE:undoMove();break;case SHUFFLE:shuffleRemaining();delay=2000;break;case UNDO_CORRECT:undoFrom('correct');break;case UNDO_INCORRECT:undoFrom('incorrect');break;case SHOW_HELP:showHelp();break;case TOGGLE_AUTO_PLAY:toggleAutoPlay();break;case SET_AUTO_SPEED:setAutoPlaySpeed();break;}
noActionsUntil=now+ delay;uiEventForAdFlips();}
function showHelp(){pauseTimer();infoCardContent.html($('#flashcardHelp').html());infoCard.show();}
function moveCurrentToCorrect(){moveCardTo('correct',true);setTimeout('getNextCard()',300);}
function moveCurrentToIncorrect(){moveCardTo('incorrect',true);setTimeout('getNextCard()',300);}
function moveCurrentToRemaining(){if(currentCard.css('display')=='block'){moveCardTo('remaining',false);setTimeout('getNextCard()',350);}}
function processKeyPress(event){var key=keyCode(event);switch(key){case SHIFT_KEY:case ENTER_KEY:case SPACEBAR_KEY:usedSpaceBar=true;doAction(FLIP_CARD);break;case LEFT_ARROW_KEY:usedUndo=true;doAction(UNDO_MOVE);break;case C_KEY:case R_KEY:case UP_ARROW_KEY:usedUpOrDownKeys=true;doAction(MOVE_TO_CORRECT);break;case RIGHT_ARROW_KEY:doAction(MOVE_TO_REMAINING);break;case I_KEY:case W_KEY:case DOWN_ARROW_KEY:usedUpOrDownKeys=true;doAction(MOVE_TO_INCORRECT);break;default:return;}
if(event.preventDefault){event.preventDefault();}
else{event.returnValue=false;}}
function moveCardTo(pileName,pileTop){if(currentCard.css('display')=='block'){if(pileName!='remaining'){moveHistory[moveHistory.length]=getPileId(pileName);}
animateMovingCurrentCardTo(pileName,pileTop,function(){finishMoveTo(pileName,pileTop);adjustCount(pileName,1);});}}
function animateMovingCurrentCardTo(pileName,pileTop,completeFunc){animateMovingCardTo(currentCard,pileName,200,pileTop,completeFunc);}
function animateMovingCardTo(card,pileName,duration,pileTop,completeFunc){card.show();card.css('zIndex',pileTop?10:1);var properties={};var pile=$('#'+ pileName+'Cards');properties.top=pile.css('top');properties.left=pile.css('left');properties.width=pile.css('width');properties.height=pile.css('height');var fontSize=card.css('fontSize');debug('animateMovingCardTo '+ pileName+' card fontsize='+ fontSize+' new fontsize will be '+ properties.fontSize);card.animate(properties,duration,'linear',completeFunc);}
function undoMove(){if(moveHistory.length>0){var delay=0;moveCardTo('remaining',true);delay=300;var source=getPileName(moveHistory[moveHistory.length- 1]);moveHistory.length--;setTimeout("moveToCenter('"+ source+"')",delay);}}
function undoFrom(pileName){usedUndo=true;moveCardTo('remaining',true);var i=moveHistory.length- 1;while(getPileName(moveHistory[i])!=pileName){i--;}
moveHistory.splice(i,1);setTimeout("moveToCenter('"+ pileName+"')",300);}
function flipCard(){if(currentSide==0&&clickToFlipColor<255){clickToFlipColor=clickToFlipColor+ 5;}
currentSide=(currentSide+ 1)%stack.columnNames.length;animateFlip();}
var normalProperties={};function animateFlip(){normalProperties.top=currentCard.css('top');normalProperties.height=currentCard.css('height');var halfProperties={};halfProperties.top=parseInt(normalProperties.top)+ parseInt(normalProperties.height)/2- 2;halfProperties.height=2;currentCard.animate(halfProperties,50,'linear',finishFlip);}
function finishFlip(){initCurrentCardHtml(currentCardIndex,currentSide);currentCard.animate(normalProperties,50,'linear');}
function initCurrentCardHtml(cardIndex,side){initCardHtml(currentCard,cardIndex,side);}
var sideColor=Array(10);sideColor[0]="#ffffff";sideColor[1]="#DFEDFE";sideColor[2]="#ffdddd";sideColor[3]="#ddffdd";sideColor[4]="#ddddff";sideColor[5]="#cc9999";sideColor[6]="#99ee99";sideColor[7]="#9999ee";sideColor[8]="#6666cc";sideColor[9]="#cc6666";function initCardHtml(card,cardIndex,side){debug('initCardHtml '+ card+' cardIndex='+ cardIndex+'side='+ side);if(reverseOrderCheckBox&&reverseOrderCheckBox.checked){side=stack.columnNames.length- side- 1;}
var text=stack.data[cardIndex][side];debug('text='+ text);var clickToFlip='';if(side==0){clickToFlip="<div id='clickToFlip' style='color: rgb("+ clickToFlipColor+","+ clickToFlipColor+","+ clickToFlipColor+")'> </div>";}
card.html('<h2>'+ stack.columnNames[side]+'</h2>'+'<table><tr><td style="font-size:'+ getAppropriateFontSize(text)+'%">'+
text+'</td></tr></table>'+ clickToFlip);card.css('backgroundColor',sideColor[side]);var className=(card==currentCard)?'linedCard':'linedCardSmall';if(side==0){card.addClass(className);}
else{card.removeClass(className);}}
function reverseOrder(){continueTimer();currentSide=0;refreshUI();}
function refreshUI(){initCurrentCardHtml(currentCardIndex,currentSide);showPileTop('correct');showPileTop('incorrect');showPileTop('remaining');}
function initPileTopWithCard(pile,cardNumber){initCardHtml(pile,cardNumber,0);}
function adjustCount(pileName,adjustment){var newCount;if(adjustment==0){newCount=0;}
else{newCount=getCount(pileName)+ adjustment;}
setCount(pileName,newCount);}
function getCount(pileName){var counter=document.getElementById(pileName+'Box');var pile=document.getElementById(pileName+'Cards');var text=counter.innerHTML;text=text.substr(text.indexOf('(')+ 1);return parseInt(text);}
function setCount(pileName,newCount){var counter=document.getElementById(pileName+'Box');var pile=document.getElementById(pileName+'Cards');counter.innerHTML=pileName+" cards ("+ newCount+")";if(newCount==0){pile.style.display='none'}
else{pile.style.display='block'}}
function showPileTop(pileName){var pile=$('#'+ pileName+'Cards');var pilesCards=cardIndexes[pileName];debug('  pilesCards.length = '+ pilesCards.length);if(pilesCards.length>0){initPileTopWithCard(pile,pilesCards[pilesCards.length- 1]);}}
function finishMoveTo(pileName,pileTop){var pile=$('#'+ pileName+'Cards');var pilesCards=cardIndexes[pileName];if(pileTop||pilesCards.length==0){pilesCards[pilesCards.length]=currentCardIndex;initPileTopWithCard(pile,currentCardIndex);}
else{pilesCards.splice(0,0,currentCardIndex);}
currentCard.css('display','none');debug('finishMoveTo '+ pileName+' pileTop='+ pileTop+' pileCards contains '+ pilesCards.length+' currentCardIndex='+ currentCardIndex);}
var cardsProcessed=0;function getNextCard(){if((getCount('remaining')==0)&&currentCard.css('display')!='block'){showPassCompleteCard();currentCardIndex=-1;}
else{moveToCenter('remaining');cardsProcessed++;}}
function displayNextTip(){var tip='';if(cardsProcessed>50&&!usedPause){tip='TIP: If you need to use the arrow keys to scroll the page, click on the Pause button to allow the arrow keys to work as they do on other pages.';cardsProcessed=0;}
else if(cardsProcessed>40&&!usedUndo){tip='TIP: If you accidentally put the current card in the wrong box, click the card or press the LEFT ARROW key to undo the move.';}
else if(cardsProcessed>30&&!usedRetry&&(cardIndexes['incorrect'].length>5)){tip='TIP: Once you have moved a bunch of cards to the incorrect box you should retry those cards using the "retry" link below the box';}
else if(cardsProcessed>20&&!usedUpOrDownKeys){tip='TIP: Move cards to the correct or incorrect boxes quicker by using the UP and DOWN keys.';}
else if(cardsProcessed>10&&!usedSpaceBar){tip='TIP: You can use the spacebar key to flip the current card.';}
if(tip==''){$('#tipBox').hide();}
else{$('#tipBox').html(tip);$('#tipBox').show();}}
function showPassCompleteCard(){pauseTimer();infoCardContent.html('');var score=Math.round(getCount('correct')/stack.data.length*100);$('#correctBoxInfo').html(score+'%');$('#elapsedTimeInfo').html(timerArea.innerHTML);$('#retriesInfo').html(retries);if(score==100){$('#retryInfoLink').hide();}
else{$('#retryInfoLink').show();}
infoCardContent.html($('#congratsInfo').html());infoCard.show();}
function animateMoveToCenter(fromPileName){var pile=$('#'+ fromPileName+'Cards');currentCard.css('zIndex',5);currentCard.css('top',pile.css('top'));currentCard.css('left',pile.css('left'));currentCard.css('height',pile.css('height'));currentCard.css('width',pile.css('width'));initCurrentCardHtml(currentCardIndex,currentSide);currentCard.css('display','block');var properties={};properties.top=20;properties.left=228;properties.width=400;properties.height=322;$(currentCard).animate(properties,100,'linear');}
function getAppropriateFontSize(cardText){var length=cardText.length;var size;if(length>255){size=18;}
else if(length<13){size=Math.round(length*-5+ 105);}
else{size=Math.round(length*-0.0826446+ 41);}
debug('appropriate font size ======> for '+ cardText.length+' characters is '+ size+'%');return size;}
function getPositionProps(pileName){var pile=$('#'+ pileName+'Cards');var properties=new Object();properties.top=pile.css('top');properties.left=pile.css('left');properties.width=pile.css('width');properties.height=pile.css('height');debug('in get left='+ properties.left);return properties;}
function moveToCenter(fromPileName){var count=getCount(fromPileName);if(count>0){currentSide=0;var pilesCards=cardIndexes[fromPileName];currentCardIndex=pilesCards[pilesCards.length- 1];debug('moving '+ currentCardIndex+' to center ');pilesCards.length--;animateMoveToCenter(fromPileName);adjustCount(fromPileName,-1);if(count>1){var pile=$('#'+ fromPileName+'Cards');initPileTopWithCard(pile,pilesCards[pilesCards.length- 1]);}}}
function getPileName(pileId){switch(parseInt(pileId)){case 0:return'correct';case 1:return'incorrect';case 2:return'remaining';}
debug('bad id passed to getPileName: '+ pileId+'.');}
function getPileId(pileName){switch(pileName){case'correct':return 0;case'incorrect':return 1;case'remaining':return 2;}
debug('bad pileName passed to getPileId: '+ pileName+'.');}
function fixMoveHistory(){var correctCards=getCount('correct');moveHistory=new Array();var correctId=getPileId('correct');for(var i=0;i<correctCards;i++){moveHistory[moveHistory.length]=correctId;}}
function retry(){usedRetry=true;if(getCount('incorrect')>0){retries++;if(currentCard.css('display')=='block'){moveCardTo('remaining',true)}
setTimeout("moveIncorrectToRemaining()",200);setTimeout('getNextCard()',900);fixMoveHistory();}}
var incProps;var correctProps;function moveIncorrectToRemaining(){var numIncorrect=getCount('incorrect');if(numIncorrect>0){incorrectCards.css('zIndex',10);adjustCount('incorrect',0);animateMovingCardTo(incorrectCards,'remaining',200,true);incProps=getPositionProps('incorrect');setTimeout('finishMoveIncorrectToRemaining('+ numIncorrect+')',400);}}
function finishMoveIncorrectToRemaining(numCardsMoved){incorrectCards.hide();var incorrectCardIndexes=cardIndexes['incorrect'];var remainingCards=cardIndexes['remaining'];shuffle(incorrectCardIndexes);for(var i=0;i<incorrectCardIndexes.length;i++){remainingCards[remainingCards.length]=incorrectCardIndexes[i];}
adjustCount('remaining',numCardsMoved);incorrectCards.animate(incProps,0);var pile=$('#remainingCards');var pilesCards=cardIndexes['remaining'];initPileTopWithCard(pile,pilesCards[pilesCards.length- 1]);incorrectCardIndexes.length=0;incorrectCards.css('zIndex',3);}
function moveCorrectToRemaining(){var numCorrect=getCount('correct');if(numCorrect>0){adjustCount('correct',0);animateMovingCardTo(correctCards,'remaining',200,true);correctProps=getPositionProps('correct');setTimeout('finishMoveCorrectToRemaining('+ numCorrect+')',200);}}
function finishMoveCorrectToRemaining(numCardsMoved){adjustCount('remaining',numCardsMoved);correctCards.hide();correctCards.animate(correctProps,0);}
var moveHistory;function shuffleRemaining(){var pilesCards=cardIndexes['remaining'];if(pilesCards.length==0){return;}
finishShuffle();moveCardTo('remaining',true);shakeRemainingPile();setTimeout("finishShuffle()",400);setTimeout("finishShuffle()",600);setTimeout('getNextCard()',1200);}
function shakeRemainingPile(){remainingCards.animate({left:665,top:97},50).animate({left:660,top:100},50).animate({left:655,top:103},50).animate({left:660,top:100},50).animate({left:665,top:97},50).animate({left:660,top:100},50)}
function finishShuffle(){var pilesCards=cardIndexes['remaining'];shuffle(pilesCards);var pile=$('#remainingCards');initPileTopWithCard(pile,pilesCards[pilesCards.length- 1]);}
function shuffle(a){var i;var tmp;var r;for(i=0;i<a.length;i++){r=Math.floor(Math.random()*i);tmp=a[r];a[r]=a[i];a[i]=tmp;}}
function startOver(){retries=0;currentCard=$('#currentCard');currentSide=0;remainingCards=$('#remainingCards');incorrectCards=$('#incorrectCards');correctCards=$('#correctCards');pauseButton=$('#pause');infoCard=$('#infoCard');infoCardContent=$('#infoCardContent');reverseOrderCheckBox=document.getElementById('reverseOrderCheckBox');elapsedTime=0;startTime=new Date().getTime();moveHistory=new Array();var delay=0;if(currentCard.css('display')=='block'){moveCardTo('remaining',true);delay++;}
if(getCount('correct')>0){setTimeout('moveCorrectToRemaining()',delay*100);delay++;}
if(getCount('incorrect')>0){setTimeout('moveIncorrectToRemaining()',delay*100);delay++;}
setTimeout('finishStart()',delay*300);debug('startOver complete');}
function finishStart(){cardIndexes=new Array();cardIndexes['correct']=createInitialOrderArray(0);cardIndexes['incorrect']=createInitialOrderArray(0);cardIndexes['remaining']=createInitialOrderArray(stack.data.length);setCount('remaining',stack.data.length);setCount('correct',0);setCount('incorrect',0);if(savedSessionData.length>10){debug('savedSessionData.length='+ savedSessionData.length);restoreBoxStates(savedSessionData);}
else{shakeRemainingPile();var pilesCards=cardIndexes['remaining'];var pile=$('#remainingCards');initPileTopWithCard(pile,pilesCards[pilesCards.length- 1]);setTimeout('getNextCard()',700);}
if(window.location==window.parent.location){continueTimer();}}
var elapsedTime=0;var timer=null;var startTime=0;var timerArea=null;function delayedBlur(){if(!gameFocus){pauseTimer();}}
function pauseTimer(){paused=true;setTimeout('changeButtonToContinue()',200);if(timer!=null){clearTimeout(timer);timer=null;}
saveBoxStates();}
function changeButtonToContinue(){if(paused&&pauseButton){pauseButton.html('Continue');}}
function continueTimer(){debug('continueTimer pauseButton='+ pauseButton+' paused='+ paused);if(pauseButton){pauseButton.focus();if(paused){pauseButton.html('Pause');paused=false;}
startTime=(new Date().getTime())- elapsedTime;timer=setTimeout("updateTimerContinuously()",1);}}
function togglePause(){usedPause=true;if(blurTimer!=null){clearTimeout(blurTimer);blurTimer=null;}
if(paused){continueTimer();doAutoPlay();}
else{pauseTimer();}}
function updateTimerContinuously(){updateTimer();if(timer!=null){timer=setTimeout("updateTimerContinuously()",800);}}
function updateTimer(){if(paused)return;var currentTime=new Date().getTime();elapsedTime=currentTime- startTime;displayElapsedTime();}
function displayElapsedTime(){if(timerArea==null){timerArea=document.getElementById('timerArea');}
var elapsedSeconds=Math.floor((elapsedTime)/1000);var elapsedMinutes=Math.floor(elapsedSeconds/60);elapsedSeconds=elapsedSeconds-(60*elapsedMinutes);if(elapsedSeconds<10){elapsedSeconds="0"+ elapsedSeconds;}
timerArea.innerHTML=elapsedMinutes+":"+ elapsedSeconds;}
var autoPlayTimer=null;var autoPlayDelay=2000;var autoPlayCheckBox=document.getElementById('autoPlayCheckBox');autoPlayCheckBox.checked=false;var speedBar=document.getElementById('speedBar');var speedBarArea=document.getElementById('speedBarArea');var delayDescription=document.getElementById('delayDescription');speedBar.onmousedown=setSpeed;function setSpeed(event){debug('setSpeed 1 event='+ event);if(!event)event=window.event;debug('setSpeed 2 event='+ event);event=jQuery.event.fix(event);autoSpeedX=event.offsetX;debug('setSpeed autoSpeedX='+ autoSpeedX);doAction(SET_AUTO_SPEED);}
function setAutoPlaySpeed(){debug('setAutoPlaySpeed autoSpeedX='+ autoSpeedX);autoPlayDelay=500+ 8000.0*autoSpeedX/speedBar.offsetWidth;speedMarker.style.left=5+ autoSpeedX+'px';var num=autoPlayDelay/1000;num=num.toFixed(1);delayDescription.innerHTML='delay '+ num+' sec';paused=false;doAutoPlay();setTimeout('continueTimer()',10);}
function toggleAutoPlay(){if(autoPlayTimer!=null){clearTimeout(autoPlayTimer);autoPlayTimer=null;}
if(autoPlayCheckBox.checked){doAutoPlay();speedBarArea.style.display='block';}
else{speedBarArea.style.display='none';}}
function doAutoPlay(){if(autoPlayTimer!=null){clearTimeout(autoPlayTimer);autoPlayTimer=null;}
if(autoPlayCheckBox.checked&&!paused){if(currentSide+ 1==stack.columnNames.length){moveCurrentToRemaining();}else{flipCard();}
autoPlayTimer=setTimeout('doAutoPlay()',autoPlayDelay);}}
function restoreBox(boxName,savedIndexes){debug('restoring '+ boxName+' with '+ savedIndexes);cardIndexes[boxName]=savedIndexes;setCount(boxName,cardIndexes[boxName].length);showPileTop(boxName);}
function saveBoxStates(){if((cardIndexes['correct'].length>0)||(cardIndexes['incorrect'].length>0)){var saveState=stringifyNumArray(cardIndexes['correct'])+'|'+
stringifyNumArray(cardIndexes['incorrect'])+'|'+
stringifyNumArray(cardIndexes['remaining'])+'|'+
stringifyNumArray(moveHistory)+'|'+
currentSide+'|'+
currentCardIndex+'|'+
retries+'|'+
elapsedTime;debug('saving '+ saveState);sendAjaxSaveSessionMessage(studyStackId,saveState);}}
function inArray(theArray,theValue){for(var i=0;i<theArray.length;i++){if(theArray[i]==theValue){return true;}}
return false;}
function restoreBoxStates(saveState){savedSessionData='';debug('restoring '+ saveState);var savedParts=saveState.split('|');var correctCardsState=savedParts[0].split(",");var incorrectCardsState=savedParts[1].split(",");var remainingCards=[];var correctCards=[];var incorrectCards=[];currentCardIndex=savedParts[5];for(var index=0;index<stack.data.length;index++){if(index==currentCardIndex){}else if(inArray(correctCardsState,index)){correctCards[correctCards.length]=index;}else if(inArray(incorrectCardsState,index)){incorrectCards[incorrectCards.length]=index;}
else{remainingCards[remainingCards.length]=index;}}
restoreBox('correct',correctCards);restoreBox('incorrect',incorrectCards);restoreBox('remaining',remainingCards);moveHistory=savedParts[3].split(",");debug('moveHistory length is '+ moveHistory.length);currentSide=savedParts[4];debug('currentSide='+ currentSide);currentCardIndex=savedParts[5];retries=savedParts[6];elapsedTime=savedParts[7];displayElapsedTime();debug('currentCardIndex = '+ currentCardIndex);var numCards=cardIndexes['correct'].length+ cardIndexes['incorrect'].length+ cardIndexes['remaining'].length;if(currentCardIndex==-1){showPassCompleteCard();}
else{debug('init current card to '+ currentCardIndex+' side: '+ currentSide);initCurrentCardHtml(currentCardIndex,currentSide);currentCard.css('display','block');numCards++;}
if(numCards!=stack.data.length){startOver();}}
function debug(msg){}
function stringifyNumArray(array){var str='';for(var i=0;i<array.length;i++){str=str+ array[i]+',';}
if(array.length>0){str=str.substr(0,str.length- 1);}
return str;}
