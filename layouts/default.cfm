<cfsilent>
	<cfparam name="session.userID" default="" />
</cfsilent>

<cfif cgi.SCRIPT_NAME DOES NOT CONTAIN '.cfc'>
	<!DOCTYPE html>
	<!--[if lt IE 7]> <html class="lt-ie9 lt-ie8 lt-ie7" lang="en"> <![endif]-->
	<!--[if IE 7]>    <html class="lt-ie9 lt-ie8" lang="en"> <![endif]-->
	<!--[if IE 8]>    <html class="lt-ie9" lang="en"> <![endif]-->
	<!--[if gt IE 8]><!-->
	<html lang="en"><!--<![endif]-->
	<head>
		<meta charset="utf-8">
		<title>
			<cfif structKeyExists(rc, "filter") AND len(rc.filter.getTitle())>
				<cfoutput>#rc.filter.getTitle()#</cfoutput>
			<cfelse>
				STO .:. The New Generation of Corporate Online Booking
			</cfif>
		</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<meta name="description" content="Short's Travel Online">
		<meta name="author" content="Short's Travel Management">
		<cfif rc.addNewRelicBrowserJS>
		<!--New Relic Browser-->
		<script type="text/javascript">
		window.NREUM||(NREUM={}),__nr_require=function(t,n,e){function r(e){if(!n[e]){var o=n[e]={exports:{}};t[e][0].call(o.exports,function(n){var o=t[e][1][n];return r(o||n)},o,o.exports)}return n[e].exports}if("function"==typeof __nr_require)return __nr_require;for(var o=0;o<e.length;o++)r(e[o]);return r}({1:[function(t,n,e){function r(t){try{s.console&&console.log(t)}catch(n){}}var o,i=t("ee"),a=t(15),s={};try{o=localStorage.getItem("__nr_flags").split(","),console&&"function"==typeof console.log&&(s.console=!0,o.indexOf("dev")!==-1&&(s.dev=!0),o.indexOf("nr_dev")!==-1&&(s.nrDev=!0))}catch(c){}s.nrDev&&i.on("internal-error",function(t){r(t.stack)}),s.dev&&i.on("fn-err",function(t,n,e){r(e.stack)}),s.dev&&(r("NR AGENT IN DEVELOPMENT MODE"),r("flags: "+a(s,function(t,n){return t}).join(", ")))},{}],2:[function(t,n,e){function r(t,n,e,r,o){try{d?d-=1:i("err",[o||new UncaughtException(t,n,e)])}catch(s){try{i("ierr",[s,c.now(),!0])}catch(u){}}return"function"==typeof f&&f.apply(this,a(arguments))}function UncaughtException(t,n,e){this.message=t||"Uncaught error with no additional information",this.sourceURL=n,this.line=e}function o(t){i("err",[t,c.now()])}var i=t("handle"),a=t(16),s=t("ee"),c=t("loader"),f=window.onerror,u=!1,d=0;c.features.err=!0,t(1),window.onerror=r;try{throw new Error}catch(l){"stack"in l&&(t(8),t(7),"addEventListener"in window&&t(5),c.xhrWrappable&&t(9),u=!0)}s.on("fn-start",function(t,n,e){u&&(d+=1)}),s.on("fn-err",function(t,n,e){u&&(this.thrown=!0,o(e))}),s.on("fn-end",function(){u&&!this.thrown&&d>0&&(d-=1)}),s.on("internal-error",function(t){i("ierr",[t,c.now(),!0])})},{}],3:[function(t,n,e){t("loader").features.ins=!0},{}],4:[function(t,n,e){function r(t){}if(window.performance&&window.performance.timing&&window.performance.getEntriesByType){var o=t("ee"),i=t("handle"),a=t(8),s=t(7),c="learResourceTimings",f="addEventListener",u="resourcetimingbufferfull",d="bstResource",l="resource",p="-start",h="-end",m="fn"+p,w="fn"+h,v="bstTimer",y="pushState",g=t("loader");g.features.stn=!0,t(6);var b=NREUM.o.EV;o.on(m,function(t,n){var e=t[0];e instanceof b&&(this.bstStart=g.now())}),o.on(w,function(t,n){var e=t[0];e instanceof b&&i("bst",[e,n,this.bstStart,g.now()])}),a.on(m,function(t,n,e){this.bstStart=g.now(),this.bstType=e}),a.on(w,function(t,n){i(v,[n,this.bstStart,g.now(),this.bstType])}),s.on(m,function(){this.bstStart=g.now()}),s.on(w,function(t,n){i(v,[n,this.bstStart,g.now(),"requestAnimationFrame"])}),o.on(y+p,function(t){this.time=g.now(),this.startPath=location.pathname+location.hash}),o.on(y+h,function(t){i("bstHist",[location.pathname+location.hash,this.startPath,this.time])}),f in window.performance&&(window.performance["c"+c]?window.performance[f](u,function(t){i(d,[window.performance.getEntriesByType(l)]),window.performance["c"+c]()},!1):window.performance[f]("webkit"+u,function(t){i(d,[window.performance.getEntriesByType(l)]),window.performance["webkitC"+c]()},!1)),document[f]("scroll",r,{passive:!0}),document[f]("keypress",r,!1),document[f]("click",r,!1)}},{}],5:[function(t,n,e){function r(t){for(var n=t;n&&!n.hasOwnProperty(u);)n=Object.getPrototypeOf(n);n&&o(n)}function o(t){s.inPlace(t,[u,d],"-",i)}function i(t,n){return t[1]}var a=t("ee").get("events"),s=t(18)(a,!0),c=t("gos"),f=XMLHttpRequest,u="addEventListener",d="removeEventListener";n.exports=a,"getPrototypeOf"in Object?(r(document),r(window),r(f.prototype)):f.prototype.hasOwnProperty(u)&&(o(window),o(f.prototype)),a.on(u+"-start",function(t,n){var e=t[1],r=c(e,"nr@wrapped",function(){function t(){if("function"==typeof e.handleEvent)return e.handleEvent.apply(e,arguments)}var n={object:t,"function":e}[typeof e];return n?s(n,"fn-",null,n.name||"anonymous"):e});this.wrapped=t[1]=r}),a.on(d+"-start",function(t){t[1]=this.wrapped||t[1]})},{}],6:[function(t,n,e){var r=t("ee").get("history"),o=t(18)(r);n.exports=r,o.inPlace(window.history,["pushState","replaceState"],"-")},{}],7:[function(t,n,e){var r=t("ee").get("raf"),o=t(18)(r),i="equestAnimationFrame";n.exports=r,o.inPlace(window,["r"+i,"mozR"+i,"webkitR"+i,"msR"+i],"raf-"),r.on("raf-start",function(t){t[0]=o(t[0],"fn-")})},{}],8:[function(t,n,e){function r(t,n,e){t[0]=a(t[0],"fn-",null,e)}function o(t,n,e){this.method=e,this.timerDuration="number"==typeof t[1]?t[1]:0,t[0]=a(t[0],"fn-",this,e)}var i=t("ee").get("timer"),a=t(18)(i),s="setTimeout",c="setInterval",f="clearTimeout",u="-start",d="-";n.exports=i,a.inPlace(window,[s,"setImmediate"],s+d),a.inPlace(window,[c],c+d),a.inPlace(window,[f,"clearImmediate"],f+d),i.on(c+u,r),i.on(s+u,o)},{}],9:[function(t,n,e){function r(t,n){d.inPlace(n,["onreadystatechange"],"fn-",s)}function o(){var t=this,n=u.context(t);t.readyState>3&&!n.resolved&&(n.resolved=!0,u.emit("xhr-resolved",[],t)),d.inPlace(t,w,"fn-",s)}function i(t){v.push(t),h&&(g=-g,b.data=g)}function a(){for(var t=0;t<v.length;t++)r([],v[t]);v.length&&(v=[])}function s(t,n){return n}function c(t,n){for(var e in t)n[e]=t[e];return n}t(5);var f=t("ee"),u=f.get("xhr"),d=t(18)(u),l=NREUM.o,p=l.XHR,h=l.MO,m="readystatechange",w=["onload","onerror","onabort","onloadstart","onloadend","onprogress","ontimeout"],v=[];n.exports=u;var y=window.XMLHttpRequest=function(t){var n=new p(t);try{u.emit("new-xhr",[n],n),n.addEventListener(m,o,!1)}catch(e){try{u.emit("internal-error",[e])}catch(r){}}return n};if(c(p,y),y.prototype=p.prototype,d.inPlace(y.prototype,["open","send"],"-xhr-",s),u.on("send-xhr-start",function(t,n){r(t,n),i(n)}),u.on("open-xhr-start",r),h){var g=1,b=document.createTextNode(g);new h(a).observe(b,{characterData:!0})}else f.on("fn-end",function(t){t[0]&&t[0].type===m||a()})},{}],10:[function(t,n,e){function r(t){var n=this.params,e=this.metrics;if(!this.ended){this.ended=!0;for(var r=0;r<d;r++)t.removeEventListener(u[r],this.listener,!1);if(!n.aborted){if(e.duration=a.now()-this.startTime,4===t.readyState){n.status=t.status;var i=o(t,this.lastSize);if(i&&(e.rxSize=i),this.sameOrigin){var c=t.getResponseHeader("X-NewRelic-App-Data");c&&(n.cat=c.split(", ").pop())}}else n.status=0;e.cbTime=this.cbTime,f.emit("xhr-done",[t],t),s("xhr",[n,e,this.startTime])}}}function o(t,n){var e=t.responseType;if("json"===e&&null!==n)return n;var r="arraybuffer"===e||"blob"===e||"json"===e?t.response:t.responseText;return h(r)}function i(t,n){var e=c(n),r=t.params;r.host=e.hostname+":"+e.port,r.pathname=e.pathname,t.sameOrigin=e.sameOrigin}var a=t("loader");if(a.xhrWrappable){var s=t("handle"),c=t(11),f=t("ee"),u=["load","error","abort","timeout"],d=u.length,l=t("id"),p=t(14),h=t(13),m=window.XMLHttpRequest;a.features.xhr=!0,t(9),f.on("new-xhr",function(t){var n=this;n.totalCbs=0,n.called=0,n.cbTime=0,n.end=r,n.ended=!1,n.xhrGuids={},n.lastSize=null,p&&(p>34||p<10)||window.opera||t.addEventListener("progress",function(t){n.lastSize=t.loaded},!1)}),f.on("open-xhr-start",function(t){this.params={method:t[0]},i(this,t[1]),this.metrics={}}),f.on("open-xhr-end",function(t,n){"loader_config"in NREUM&&"xpid"in NREUM.loader_config&&this.sameOrigin&&n.setRequestHeader("X-NewRelic-ID",NREUM.loader_config.xpid)}),f.on("send-xhr-start",function(t,n){var e=this.metrics,r=t[0],o=this;if(e&&r){var i=h(r);i&&(e.txSize=i)}this.startTime=a.now(),this.listener=function(t){try{"abort"===t.type&&(o.params.aborted=!0),("load"!==t.type||o.called===o.totalCbs&&(o.onloadCalled||"function"!=typeof n.onload))&&o.end(n)}catch(e){try{f.emit("internal-error",[e])}catch(r){}}};for(var s=0;s<d;s++)n.addEventListener(u[s],this.listener,!1)}),f.on("xhr-cb-time",function(t,n,e){this.cbTime+=t,n?this.onloadCalled=!0:this.called+=1,this.called!==this.totalCbs||!this.onloadCalled&&"function"==typeof e.onload||this.end(e)}),f.on("xhr-load-added",function(t,n){var e=""+l(t)+!!n;this.xhrGuids&&!this.xhrGuids[e]&&(this.xhrGuids[e]=!0,this.totalCbs+=1)}),f.on("xhr-load-removed",function(t,n){var e=""+l(t)+!!n;this.xhrGuids&&this.xhrGuids[e]&&(delete this.xhrGuids[e],this.totalCbs-=1)}),f.on("addEventListener-end",function(t,n){n instanceof m&&"load"===t[0]&&f.emit("xhr-load-added",[t[1],t[2]],n)}),f.on("removeEventListener-end",function(t,n){n instanceof m&&"load"===t[0]&&f.emit("xhr-load-removed",[t[1],t[2]],n)}),f.on("fn-start",function(t,n,e){n instanceof m&&("onload"===e&&(this.onload=!0),("load"===(t[0]&&t[0].type)||this.onload)&&(this.xhrCbStart=a.now()))}),f.on("fn-end",function(t,n){this.xhrCbStart&&f.emit("xhr-cb-time",[a.now()-this.xhrCbStart,this.onload,n],n)})}},{}],11:[function(t,n,e){n.exports=function(t){var n=document.createElement("a"),e=window.location,r={};n.href=t,r.port=n.port;var o=n.href.split("://");!r.port&&o[1]&&(r.port=o[1].split("/")[0].split("@").pop().split(":")[1]),r.port&&"0"!==r.port||(r.port="https"===o[0]?"443":"80"),r.hostname=n.hostname||e.hostname,r.pathname=n.pathname,r.protocol=o[0],"/"!==r.pathname.charAt(0)&&(r.pathname="/"+r.pathname);var i=!n.protocol||":"===n.protocol||n.protocol===e.protocol,a=n.hostname===document.domain&&n.port===e.port;return r.sameOrigin=i&&(!n.hostname||a),r}},{}],12:[function(t,n,e){function r(){}function o(t,n,e){return function(){return i(t,[f.now()].concat(s(arguments)),n?null:this,e),n?void 0:this}}var i=t("handle"),a=t(15),s=t(16),c=t("ee").get("tracer"),f=t("loader"),u=NREUM;"undefined"==typeof window.newrelic&&(newrelic=u);var d=["setPageViewName","setCustomAttribute","setErrorHandler","finished","addToTrace","inlineHit","addRelease"],l="api-",p=l+"ixn-";a(d,function(t,n){u[n]=o(l+n,!0,"api")}),u.addPageAction=o(l+"addPageAction",!0),u.setCurrentRouteName=o(l+"routeName",!0),n.exports=newrelic,u.interaction=function(){return(new r).get()};var h=r.prototype={createTracer:function(t,n){var e={},r=this,o="function"==typeof n;return i(p+"tracer",[f.now(),t,e],r),function(){if(c.emit((o?"":"no-")+"fn-start",[f.now(),r,o],e),o)try{return n.apply(this,arguments)}finally{c.emit("fn-end",[f.now()],e)}}}};a("setName,setAttribute,save,ignore,onEnd,getContext,end,get".split(","),function(t,n){h[n]=o(p+n)}),newrelic.noticeError=function(t){"string"==typeof t&&(t=new Error(t)),i("err",[t,f.now()])}},{}],13:[function(t,n,e){n.exports=function(t){if("string"==typeof t&&t.length)return t.length;if("object"==typeof t){if("undefined"!=typeof ArrayBuffer&&t instanceof ArrayBuffer&&t.byteLength)return t.byteLength;if("undefined"!=typeof Blob&&t instanceof Blob&&t.size)return t.size;if(!("undefined"!=typeof FormData&&t instanceof FormData))try{return JSON.stringify(t).length}catch(n){return}}}},{}],14:[function(t,n,e){var r=0,o=navigator.userAgent.match(/Firefox[\/\s](\d+\.\d+)/);o&&(r=+o[1]),n.exports=r},{}],15:[function(t,n,e){function r(t,n){var e=[],r="",i=0;for(r in t)o.call(t,r)&&(e[i]=n(r,t[r]),i+=1);return e}var o=Object.prototype.hasOwnProperty;n.exports=r},{}],16:[function(t,n,e){function r(t,n,e){n||(n=0),"undefined"==typeof e&&(e=t?t.length:0);for(var r=-1,o=e-n||0,i=Array(o<0?0:o);++r<o;)i[r]=t[n+r];return i}n.exports=r},{}],17:[function(t,n,e){n.exports={exists:"undefined"!=typeof window.performance&&window.performance.timing&&"undefined"!=typeof window.performance.timing.navigationStart}},{}],18:[function(t,n,e){function r(t){return!(t&&t instanceof Function&&t.apply&&!t[a])}var o=t("ee"),i=t(16),a="nr@original",s=Object.prototype.hasOwnProperty,c=!1;n.exports=function(t,n){function e(t,n,e,o){function nrWrapper(){var r,a,s,c;try{a=this,r=i(arguments),s="function"==typeof e?e(r,a):e||{}}catch(f){l([f,"",[r,a,o],s])}u(n+"start",[r,a,o],s);try{return c=t.apply(a,r)}catch(d){throw u(n+"err",[r,a,d],s),d}finally{u(n+"end",[r,a,c],s)}}return r(t)?t:(n||(n=""),nrWrapper[a]=t,d(t,nrWrapper),nrWrapper)}function f(t,n,o,i){o||(o="");var a,s,c,f="-"===o.charAt(0);for(c=0;c<n.length;c++)s=n[c],a=t[s],r(a)||(t[s]=e(a,f?s+o:o,i,s))}function u(e,r,o){if(!c||n){var i=c;c=!0;try{t.emit(e,r,o,n)}catch(a){l([a,e,r,o])}c=i}}function d(t,n){if(Object.defineProperty&&Object.keys)try{var e=Object.keys(t);return e.forEach(function(e){Object.defineProperty(n,e,{get:function(){return t[e]},set:function(n){return t[e]=n,n}})}),n}catch(r){l([r])}for(var o in t)s.call(t,o)&&(n[o]=t[o]);return n}function l(n){try{t.emit("internal-error",n)}catch(e){}}return t||(t=o),e.inPlace=f,e.flag=a,e}},{}],ee:[function(t,n,e){function r(){}function o(t){function n(t){return t&&t instanceof r?t:t?c(t,s,i):i()}function e(e,r,o,i){if(!l.aborted||i){t&&t(e,r,o);for(var a=n(o),s=h(e),c=s.length,f=0;f<c;f++)s[f].apply(a,r);var d=u[y[e]];return d&&d.push([g,e,r,a]),a}}function p(t,n){v[t]=h(t).concat(n)}function h(t){return v[t]||[]}function m(t){return d[t]=d[t]||o(e)}function w(t,n){f(t,function(t,e){n=n||"feature",y[e]=n,n in u||(u[n]=[])})}var v={},y={},g={on:p,emit:e,get:m,listeners:h,context:n,buffer:w,abort:a,aborted:!1};return g}function i(){return new r}function a(){(u.api||u.feature)&&(l.aborted=!0,u=l.backlog={})}var s="nr@context",c=t("gos"),f=t(15),u={},d={},l=n.exports=o();l.backlog=u},{}],gos:[function(t,n,e){function r(t,n,e){if(o.call(t,n))return t[n];var r=e();if(Object.defineProperty&&Object.keys)try{return Object.defineProperty(t,n,{value:r,writable:!0,enumerable:!1}),r}catch(i){}return t[n]=r,r}var o=Object.prototype.hasOwnProperty;n.exports=r},{}],handle:[function(t,n,e){function r(t,n,e,r){o.buffer([t],r),o.emit(t,n,e)}var o=t("ee").get("handle");n.exports=r,r.ee=o},{}],id:[function(t,n,e){function r(t){var n=typeof t;return!t||"object"!==n&&"function"!==n?-1:t===window?0:a(t,i,function(){return o++})}var o=1,i="nr@id",a=t("gos");n.exports=r},{}],loader:[function(t,n,e){function r(){if(!x++){var t=b.info=NREUM.info,n=l.getElementsByTagName("script")[0];if(setTimeout(u.abort,3e4),!(t&&t.licenseKey&&t.applicationID&&n))return u.abort();f(y,function(n,e){t[n]||(t[n]=e)}),c("mark",["onload",a()+b.offset],null,"api");var e=l.createElement("script");e.src="https://"+t.agent,n.parentNode.insertBefore(e,n)}}function o(){"complete"===l.readyState&&i()}function i(){c("mark",["domContent",a()+b.offset],null,"api")}function a(){return E.exists&&performance.now?Math.round(performance.now()):(s=Math.max((new Date).getTime(),s))-b.offset}var s=(new Date).getTime(),c=t("handle"),f=t(15),u=t("ee"),d=window,l=d.document,p="addEventListener",h="attachEvent",m=d.XMLHttpRequest,w=m&&m.prototype;NREUM.o={ST:setTimeout,CT:clearTimeout,XHR:m,REQ:d.Request,EV:d.Event,PR:d.Promise,MO:d.MutationObserver};var v=""+location,y={beacon:"bam.nr-data.net",errorBeacon:"bam.nr-data.net",agent:"js-agent.newrelic.com/nr-1026.min.js"},g=m&&w&&w[p]&&!/CriOS/.test(navigator.userAgent),b=n.exports={offset:s,now:a,origin:v,features:{},xhrWrappable:g};t(12),l[p]?(l[p]("DOMContentLoaded",i,!1),d[p]("load",r,!1)):(l[h]("onreadystatechange",o),d[h]("onload",r)),c("mark",["firstbyte",s],null,"api");var x=0,E=t(17)},{}]},{},["loader",2,10,4,3]);
		;NREUM.info={beacon:"bam.nr-data.net",errorBeacon:"bam.nr-data.net",licenseKey:"37f81512ca",applicationID:"43007793",sa:1}
		</script>
		</cfif>
		<cfoutput>
			<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" integrity="sha384-1q8mTJOASx8j1Au+a5WDVnPi2lkFfwwEAa8hDDdjZlpLegxhjVME1fgjWPGmkzs7" crossorigin="anonymous">
			<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap-theme.min.css" integrity="sha384-fLW2N01lMqjakBkx3l/M9EahuwpSfeNvV63J5ezn3uZzapT0u7EYsXMjQV+0En5r" crossorigin="anonymous">
			<link href="//code.jquery.com/ui/1.9.2/themes/smoothness/jquery-ui.css" rel="stylesheet" media="screen">

			<!--[if IE 7]>
				<link rel="stylesheet" href="assets/css/font-awesome-ie7.min.css" media="screen">
			<![endif]-->
			<link href="assets/css/bootstrap-drawer.min.css?v=#application.staticAssetVersion#" rel="stylesheet" media="screen">
			<link href="assets/css/layout.css?v=#application.staticAssetVersion#" rel="stylesheet" media="screen">
			<link href="assets/css/style.css?v=#application.staticAssetVersion#" rel="stylesheet" media="screen">
			<link href="assets/css/print.css?v=#application.staticAssetVersion#" rel="stylesheet" media="print">
			<link href='https://fonts.googleapis.com/css?family=Open+Sans' rel='stylesheet' type='text/css'>
			<link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">

			<!--- override header colors for TMC so their light logos will display properly --->
			<cfif structKeyExists(rc,"account") AND StructKeyExists(rc.account,"tmc") AND rc.account.tmc.getIsExternal() EQ 1>
				<style type="text/css">
					##main-header {background-color: ##292929}
					##header-top {background-color: ##F1F1F1}
					##main-nav ul li.active, ##main-nav ul li:hover {background-color: ##555}
				</style>
			</cfif>

			<!--- overried header colors if getPassthrough is sent from widget - usually for other shorts accounts
				These can be set in account config and passed on URL from widget	--->
			<cfif structKeyExists(rc,"filter") AND rc.filter.getPassthrough() EQ 1>
				<style type="text/css">
					body {background-color: ###rc.filter.getBodyColor()#;}
					##main-header, ##header-top {background-color: ###rc.filter.getHeaderColor()#;}
				</style>
			</cfif>

			<!--[if lt IE 9]>
				<script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
			<![endif]-->
			<script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.2/jquery.min.js"></script>
			<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js" integrity="sha384-0mSbJDEHialfmuBBQP6A4Qrprq5OVfW37PRR3j5ELqxss1yVqOtnepnHVP9aJ7xS" crossorigin="anonymous"></script>
			<script src="https://ajax.googleapis.com/ajax/libs/jqueryui/1.10.3/jquery-ui.min.js"></script>
			<script src="https://use.fontawesome.com/4ba3a7fb90.js"></script>
			<script src="assets/js/jquery.plugins.min.js"></script>
			<script src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.5.1/moment.min.js"></script>
			<script src="//cdnjs.cloudflare.com/ajax/libs/underscore.js/1.6.0/underscore-min.js"></script>
			<script type="text/javascript" charset="UTF-8" src="assets/js/responsive-paginate.js"></script>
			<script type="text/javascript" charset="UTF-8" src="assets/js/js.cookie.js"></script>
			<script type="text/javascript" charset="UTF-8" src="assets/js/drawer.min.js"></script>
			<script type="text/javascript" charset="UTF-8" src="assets/js/booking.js?v=201703094"></script>
		</cfoutput>
	</head>
	<body>
		<div id="main-wrapper" class="wide">
			<header id="main-header">

				<div id="header-top">
					<nav class="navbar navbar-inverse">
  							<!-- Brand and toggle get grouped for better mobile display -->
 							<div class="navbar-header">
 							  <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar-collapse-1" aria-expanded="false">
 								<span class="sr-only">Toggle navigation</span>
 								<span class="icon-bar"></span>
 								<span class="icon-bar"></span>
								<span class="icon-bar"></span>
 							  </button>
							<cfoutput>

							<cfif NOT structKeyExists(rc,"account") OR listFind("main.login,main.logout",request.context.action)>

								<a class="navbar-brand" id="mainlogo">
									<img src="/booking/assets/img/clients/STO-Logo.png" alt="Shorts Travel Management" class="img-responsive">
								</a>

							<cfelseif rc.account.tmc.getIsExternal() EQ 1>

								<div id="logo-container">
									<div id="header">
										<cfif structKeyExists(session,"acctId") AND session.acctId EQ 532>
											<a class="navbar-brand" id="mainlogo"  href="https://www.shortstravel.com/TravelPortalV2/mcv" title="Home">
										<cfelseif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
											<a class="navbar-brand" id="mainlogo"  href="?action=main.menu" title="Home">
										<cfelse>
											<a href="#application.sPortalURL#" title="Home">
										</cfif>
											<img src="assets/img/logos/findit-logo.png" alt="FindIt" class="pull-left">
										</a>
										<div id="headerContent">
											<cfif structKeyExists(rc, "account")
												AND isStruct(rc.account)
												AND NOT structIsEmpty(rc.account)
												AND rc.account.acct_ID NEQ 1
												AND len(trim(rc.account.account_logo))
												AND FileExists("http://www.shortstravel.com/TravelPortalV2/Images/Clients/#URLEncodedFormat(rc.account.account_logo)#")>
												<img src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.account_logo#" alt="#rc.account.account_name#" class="pull-right" />
											</cfif>
										</div>
									</div>
								</div> <!--- // logo-container --->

							<cfelse>

								<cfif structKeyExists(session,"acctId") AND session.acctId EQ 532>

									<a class="navbar-brand" id="mainlogo"  href="https://www.shortstravel.com/TravelPortalV2/mcv" title="Home">

								<cfelseif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
									<a class="navbar-brand" id="mainlogo"  href="?action=main.menu" title="Home">
								<cfelseif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getSiteUrl()))>
									<a class="navbar-brand" id="mainlogo"  href="#rc.filter.getSiteUrl()#" title="Home">
								<cfelse>
									<a class="navbar-brand" id="mainlogo"  href="#application.sPortalURL#" title="Home">
								</cfif>
									<!--- <cfif structKeyExists(rc, "account")
										AND isStruct(rc.account)
										AND NOT structIsEmpty(rc.account)
										AND rc.account.acct_ID NEQ 1
										AND len(trim(rc.account.account_logo))
										AND FileExists("http://www.shortstravel.com/TravelPortalV2/Images/Clients/#URLEncodedFormat(rc.account.account_logo)#")>
										<img src="https://www.shortstravel.com/TravelPortalV2/Images/Clients/#rc.account.account_logo#" alt="#rc.account.account_name#"/>
									<cfelse> --->
										<img src="/booking/assets/img/clients/STO-Logo.png" alt="Short's Travel Management" />
									<!--- </cfif> --->
								</a>
							</div> <!-- // navbar-header -->
							</cfif>

							#View('main/navigation')#

							</cfoutput>

							<cfif structKeyExists(rc, 'filter')
								AND rc.Filter.getProfileID() NEQ rc.Filter.getUserID()>
								<div id="onbehalfof">
									Booking on behalf of
									<cfif rc.Filter.getProfileID() NEQ 0>
										<cfoutput>#rc.Filter.getProfileUsername()#</cfoutput>
									<cfelse>
										Guest Traveler
									</cfif>
								</div>
							</cfif>
					  </div><!-- /.container-fluid -->
 					</nav>
				</div> <!--- // header-top --->
				<cfoutput>#View('modal/search')#</cfoutput>
				<div id="header-bottom">
					<cfif (rc.action EQ 'air.lowfare' OR rc.action EQ 'air.availability') AND ArrayLen(StructKeyArray(session.searches)) GTE 1>
						<div class="container">
							<cfif structKeyExists(session, 'cookieToken')
								AND structKeyExists(session, 'cookieDate')>
								<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1 AND len(trim(rc.filter.getWidgetUrl()))>
									<cfset frameSrc = (cgi.https EQ 'on' ? 'https' : 'http')&'://'&cgi.Server_Name&'/search/index.cfm?'&rc.filter.getWidgetUrl() & '&token=#session.cookieToken#&date=#session.cookieDate#'/>
								<cfelse>
									<cfset frameSrc = application.searchWidgetURL  & '?acctid=#rc.filter.getAcctID()#&userid=#rc.filter.getUserId()#&token=#session.cookieToken#&date=#session.cookieDate#' />
								</cfif>
							<cfelse>
								<cfset frameSrc = ''>
							</cfif>

							<!--- button to open search in modal window --->
							<div class="one columns newsearch">
								<cfoutput>
								<a href="##" class="btn searchModalButton" data-framesrc="#frameSrc#&amp;modal=true&amp;requery=true" title="Start a new search"><i class="fa fa-search"></i></a>
								</cfoutput>
							</div>

							<!--- // end modal window --->

							<div class="fifteen columns">
								<cfoutput>#View('air/breadcrumbs')#</cfoutput>
							</div>
						</div>
					<cfelse>
						<div class="container">
							<div class="sixteen columns newsearch">
								&nbsp;
							</div>
						</div>
					</cfif>
				</div>
			</header>

			<section id="main-content">
				<cfoutput>
					#view( "cart/drawer" )#
					<div id="page-content-wrapper" class="container">
						#view( "helpers/messages" )#
						<!--- Simple test to see if session still exists. --->
						<cfif Len(session.userID) AND StructKeyExists(session, "searches")>
							#body#
						<cfelseif listFind("main.logout,main.login,dycom.login",request.context.action)>
							#body#
						<cfelse>
							<cfif structKeyExists(cookie,"loginOrigin") AND cookie.loginOrigin EQ "STO">
								<cflocation url="/booking/?action=main.logout">
							<cfelse>
								Your session has timed out due to inactivity.
								Please start a <a href="#application.sPortalURL#">NEW SEARCH</a>.
							</cfif>
						</cfif>
					</div>
				</cfoutput>
			</section>

			<footer id="footer">
				<div id="footer-top">
					<div class="container">
						<cfoutput>
					    	<cfif structKeyExists(rc, "filter") AND rc.filter.getPassthrough() EQ 1>
								<a href="mailto:#rc.filter.getSiteEmail()#">QUESTIONS/COMMENTS</a><br />
					    	<cfelse>
								#View('main/policy')#
								#View('main/unusedtickets')#
							</cfif>
						</cfoutput>
					</div>
				</div>

				<div id="footer-bottom">
					<div class="container">
						<div class="eight columns">
							Copyright Short's Travel Management <cfoutput>#Year(Now())#</cfoutput>. All Rights Reserved.
						</div>
					</div>
				</div>
			</footer>
		</div>

 		<div id="searchModal" class="bigModal modal hide fade" tabindex="-1" role="dialog" aria-labelledby="searchModalLabel" aria-hidden="true">
		<div class="modal-header">
			<button type="button" class="close" data-dismiss="modal"><i class="fa fa-remove"></i></button>
			<h3><i class="fa fa-plane"></i> FLIGHT DETAILS</h3>
		</div>
		<div class="modal-body"></div>

	</div>

	<cfoutput>
		#view('main/developers')#
	</cfoutput>

	<cfif application.es.getCurrentEnvironment() EQ "prod">
		<!--- on the new login screen these may not yet be defined --->
		<cfif structKeyExists(session,"acctId") AND val(session.acctId) AND structKeyExists(application.accounts,session.acctId)>
			<cfset account_name = ucase(application.accounts[session.acctId].account_name)/>
		<cfelse>
			<cfset account_name = "Unknown: Not Logged In"/>
		</cfif>
		<cfif structKeyExists(rc,"action") AND len(rc.action)>
			<cfset action = rc.action/>
		<cfelse>
			<cfset action = "login">
		</cfif>
		<cfoutput>
			<script type="text/javascript">
				var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
				document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
			</script>
			<script type="text/javascript">
				try {
				var pageTracker = _gat._getTracker("UA-11345476-1");
				pageTracker._setDetectFlash(0);
				pageTracker._setAllowLinker(true);
				pageTracker._setVar("#account_name#");
				pageTracker._trackPageview("#action#");
				} catch(err) {}
			</script>
		</cfoutput>
	</cfif>
	</body>
	</html>
</cfif>

<!-- %%%build-stamp%%% -->
