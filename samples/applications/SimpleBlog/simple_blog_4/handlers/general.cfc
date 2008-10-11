<!-----------------------------------------------------------------------Author 	 :	Henrik JoretegDate     :	October, 2008Description : 				This is a ColdBox event handler for general methods.Please note that the extends needs to point to the eventhandler.cfcin the ColdBox system directory.extends = coldbox.system.eventhandler	-----------------------------------------------------------------------><cfcomponent name="general" extends="coldbox.system.eventhandler" output="false" autowire="true">	<!--- Dependencies --->	<cfproperty name="EntryService" 	type="ioc" scope="instance" />	<cfproperty name="Transfer" 		type="ioc" scope="instance" />	<cfproperty name="CommentService" 	type="ioc" scope="instance" />	<cfproperty name="RSSService" 		type="ioc" scope="instance" />	<cfproperty name="DateUtil" 		type="ioc" scope="instance" />	<!----------------------------------- CONSTRUCTOR --------------------------------------->			<cffunction name="init" access="public" returntype="any" output="false" hint="constructor">		<cfargument name="controller" type="any">		<cfset super.init(arguments.controller)>		<!--- Any constructor code here --->				<cfreturn this>	</cffunction>	<!----------------------------------- PUBLIC EVENTS --------------------------------------->		<!--- index --->	<cffunction name="index" access="public" returntype="void" output="false">		<cfargument name="Event" type="any">		<cfscript>			/* Welcome message */			Event.setValue("welcomeMessage","Hello, welcome to Simple Blog!");			/* Display View */			Event.setView("home");		</cfscript>	</cffunction>		<!--- blog --->
	<cffunction name="blog" access="public" returntype="void" output="false" hint="Displays the blog page" cache="true" cachetimeout="30" >
		<cfargument name="Event" type="any" required="yes">
	    <cfset var rc = event.getCollection()>
	    	    <cfscript>	    	rc.posts = instance.EntryService.getLatestEntries();	    	Event.setView("blog");	    </cfscript>
	     
	</cffunction>			<!--- viewPost --->	<cffunction name="viewPost" access="public" returntype="void" output="false" hint="Shows one particular post and related comments" cache="true" cacheTimeout="10">		<cfargument name="Event" type="any" required="yes">	    <cfscript>	    	var rc = event.getCollection();	    	/* Get the entry */	    	rc.oPost = instance.EntryService.getEntry(rc.id);	    	/* Get Comments */	    	rc.comments = instance.CommentService.getComments(rc.id);	    	/* Set view to render */	    	Event.setView('viewPost');	    </cfscript>       	</cffunction>	<!--- doAddComment --->	<cffunction name="doAddComment" access="public" returntype="void" output="false" hint="action that adds comment">		<cfargument name="Event" type="any" required="yes">	    <cfscript>			var rc = event.getCollection();			var newComment = "";						/* new comment */			newComment = instance.CommentService.getComment();			/* Populate */			newComment.setComment(rc.commentField);		    newComment.setParentEntry(instance.EntryService.getEntry(rc.id));			/* Save Comment */			instance.CommentService.saveComment(newComment);			/* Clear Events from cache */			getColdboxOCM().clearEvent("general.viewPost","id=#rc.id#");						/* ReRoute */			setNextRoute("general/viewPost/" & rc.ID);		</cfscript>    	</cffunction>		<!--- rssEntries --->	<cffunction name="rssEntries" access="public" returntype="void" output="false" hint="Displays rss feed of entries.">		<cfargument name="Event" type="any" required="yes">				<cfscript>			var rc = event.getCollection();			var feed = instance.RSSService.getRSS(feedType=rc.feedType);			Event.renderData(type="PLAIN", data=feed);		</cfscript>	       	</cffunction>	</cfcomponent>