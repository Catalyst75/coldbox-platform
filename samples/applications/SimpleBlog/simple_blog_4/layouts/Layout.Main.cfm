<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"><html xmlns="http://www.w3.org/1999/xhtml"><head>	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1" />	<base href="<cfoutput>#getSetting('htmlbaseURL')#</cfoutput>"/>	<title><cfoutput>#rc.pageTitle#</cfoutput></title>		<link rel="stylesheet" href="includes/master.css" type="text/css">	<script src="includes/jquery.js" type="text/javascript"></script>	<script src="includes/interface.js" type="text/javascript"></script>		<script src="includes/ui.core.js" type="text/javascript"></script>	<script src="includes/myjavascript.js" type="text/javascript"></script></head><body><div class="header"><cfoutput>#renderView('head')#</cfoutput></div><div class="content">	<div class="contentInner">		<cfoutput>#renderView()#</cfoutput>	</div></div>	<div class="footer"><cfoutput>#renderView('footer')#</cfoutput></div></body></html>