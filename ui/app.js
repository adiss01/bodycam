$(document).ready(function(){
    
    $(".bodycam").hide();
    $(".odz").hide();
    window.addEventListener("message", function(event){
        if(event.data.open == true)
        {
            $(".odz").fadeIn();
            $(".bodycam").fadeIn();
            document.getElementById("data").innerHTML = event.data.date;
            document.getElementById("stopien").innerHTML = event.data.ranga;
            document.getElementById("dane").innerHTML = event.data.daneosoby;
            if (event.data.job == "sheriff") {
                document.getElementById("label").innerHTML = "BLAINE COUNTY SHERIFF OFFICE |"; 
            } else {
                document.getElementById("label").innerHTML = "LOS SANTOS POLICE DEPARTMENT |";
            }
           
        }
        else if(event.data.open == false) 
        {
            $(".odz").fadeOut();
            $(".bodycam").fadeOut();
        }
    })
});