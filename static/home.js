
function loginRequestSender(){
var xmlhttp=new XMLHttpRequest();
var target="/login/";
xmlhttp.open("POST",target);
xmlhttp.onreadystatechange=()=>{
    if(xmlhttp.readyState==4){

        if (xmlhttp.responseText=="bad_cred"){
            document.getElementById("message").innerHTML="Niepoprawny login lub hasło";
        }
        else{
            document.getElementById("message").innerHTML="Success";
        }
    }
}
var pass=document.getElementById("pass").value;
var username=document.getElementById("username").value;
if (pass.length<1 || username.length<1 ){
    document.getElementById("message").innerHTML="Błąd";
}
else{
    document.getElementById("message").innerHTML="";
var strin='{"username":"'+username+'",'+'"password":"'+pass+'"}';
var js=JSON.parse(strin);

xmlhttp.setRequestHeader("Content-Type","application/json;charset=UTF-8");
xmlhttp.send(strin);

}
}
function redirectToAccountCreation(){
    window.location="create_account";

}