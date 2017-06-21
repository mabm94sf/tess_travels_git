@RestResource(urlMapping='/travel/login/*')
global without sharing class tessLoginWS {

    @HttpPost
    global static String GetMethod(string token)
    {
        String name = UserInfo.getUserName();
        return name;
    }
}