<!-----------------------------------------------------------------------Author 	 :	Henrik JoretegDate     :	October, 2008Description :	This is a ColdBox event handler where all implicit methods can go.	Thus its the main handler.Please note that the extends needs to point to the eventhandler.cfcin the ColdBox system directory.extends = coldbox.system.eventhandler-----------------------------------------------------------------------><cfcomponent name="main" extends="coldbox.system.eventhandler" output="false" cache="true" cacheTimeout="0"><!----------------------------------- CONSTRUCTOR --------------------------------------->			<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">		<cfargument name="controller" type="any">		<cfset super.init(arguments.controller)>				<!--- Any constructor code here --->		<cfreturn this>	</cffunction><!----------------------------------- PUBLIC EVENTS --------------------------------------->		<cffunction name="onAppInit" access="public" returntype="void" output="false">		<cfargument name="Event" type="any">		<!--- ON Application Start Here --->		<!--- Create our Transfer Factory --->		<cfset var DSFile = getSetting("TransferSettings").datasourceFile>		<cfset var TFile = getSetting("TransferSettings").transferFile>		<cfset var Definitions = "/" & getSetting("AppMapping") & "/" & getSetting("TransferSettings").Definitions>		<cfset var TransferFactory = CreateObject("component","transfer.TransferFactory").init(DSFile,TFile,Definitions)>		<cfset var EntryService = 0>		<cfset var oOCM = getColdboxOCM()>		<cfset var transfer = TransferFactory.getTransfer()>				<!--- Place in Cache Indefinetely --->		<cfset oOCM.set("TransferFactory",TransferFactory, 0)>		<cfset oOCM.set("Transfer",Transfer, 0)>				<!--- Init the services --->		<cfset EntryService = createObject("component", "#getSetting('AppMapping')#.model.entries.EntryService").init(Transfer)>		<cfset CommentService = createObject("component","#getSetting('AppMapping')#.model.comments.CommentService").init(Transfer)>		<cfset oOCM.set("EntryService",EntryService, 0)>		<cfset oOCM.set("CommentService",CommentService, 0)>					</cffunction>	<cffunction name="onRequestStart" access="public" returntype="void" output="false">		<cfargument name="Event" type="any">		<cfset var rc = event.getCollection()>				<cfset event.paramValue("pageTitle","Simple Blog")>	</cffunction></cfcomponent>