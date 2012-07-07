/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

function resetTabs(){
  $("#inviteContent > div").hide(); //Hide all content
  $("#inviteTabs a").attr("id",""); //Reset id's
}

var myUrl = window.location.href; //get URL
var myUrlTab = myUrl.substring(myUrl.indexOf("#")); // For localhost/tabs.html#tab2, myUrlTab = #tab2
var myUrlTabName = myUrlTab.substring(0,4); // For the above example, myUrlTabName = #tab

(function(){
  $("#inviteContent > div").hide(); // Initially hide all content
  $("#inviteTabs li:first a").attr("id","current"); // Activate first tab
  $("#inviteContent > div:first").fadeIn(); // Show first tab content

  $("#inviteTabs a").on("click",function(e) {
    e.preventDefault();
    if ($(this).attr("id") == "current"){ //detection for current tab
      return
    }
    else{
      resetTabs();
      $(this).attr("id","current"); // Activate this
      $($(this).attr('name')).fadeIn(); // Show content for current tab
    }
  });

  for (i = 1; i <= $("#inviteTabs li").length; i++) {
    if (myUrlTab == myUrlTabName + i) {
      resetTabs();
      $("a[name='"+myUrlTab+"']").attr("id","current"); // Activate url tab
      $(myUrlTab).fadeIn(); // Show url tab content
    }
  }
})()