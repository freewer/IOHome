#IOHome

#####setup jade/sass/coffescript
```
npm install gulp-jade --save-dev //setup jade

ionic setup sass //setup sass

npm install --save-dev coffee-script //setup coffeescript
npm install --save-dev gulp-coffee //setup gulp coffee
npm install -g js2coffee //setup js to coffee
js2coffee ./www/js/script.js > ./src/coffee/script.coffee //complie js to coffee
```
[Link setup jade](http://forum.ionicframework.com/t/how-to-add-support-for-jade-templates-in-ionic/19681)

#####setup icon/splash
```
cordova plugin add org.apache.cordova.splashscreen //setup splash

ionic resources --icon //build icon (size 192*192 px)

ionic resources --splash //build splash (size 2208*2208 px)
```

#####git shell
```
cd.. //back
cd ../user/documents/github/??? //go to path ???
git status //check
git commit -am "ok" //commit "ok"
git add ???/???/??? //add path ???/???/???
git pull //sync down
git push //sync up
git merge ??? //merge ???

head //branch me
+++++ //branch you
```

#####ionic
```
ionic start <ชื่อโปรเจค> (tabs|blank|sidemenu) //create project
ionic start myApp tabs //create projectc(name app and form type)
cd myApp //open path project
ionic serve //test on browser
ionic platform add android //add platform
ionic browser add crosswalk //add armv7 and x86
ionic build android //complie apk
ionic emulate android //run emulator
ionic run android //install apk in smartphone android
ionic serve -c -l //test on browser(-b no open browser)
gulp build //recompile
```

#####color code app/splash
```
#08ae9e //base color blue&green code app
#c0c0c0 //color gray code app

#0099dd //color blue code splash
#00c193 //color green code splash
#f4f4f4 //color gray code splash
```
