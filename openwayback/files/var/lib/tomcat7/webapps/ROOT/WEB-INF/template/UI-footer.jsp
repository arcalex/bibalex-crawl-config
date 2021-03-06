<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8"%>
<%@ page import="org.archive.wayback.core.UIResults" %>
<%@ page import="org.archive.wayback.util.StringFormatter" %>
<%
UIResults results = UIResults.getGeneric(request);
StringFormatter fmt = results.getWbRequest().getFormatter();

String staticPrefix = results.getStaticPrefix();
String queryPrefix = results.getQueryPrefix();
String replayPrefix = results.getReplayPrefix();
%>
<!-- FOOTER -->
		<div align="center">
			<hr noshade size="1" align="center">
			
			<p>
				<a href="<%= staticPrefix %>">
					<%= fmt.format("UIGlobal.homeLink") %>
				</a> |
				<a href="http://web.archive.bibalex.org/web/policies/faq.html">
					FAQs
				</a> |
				<a href="http://web.archive.bibalex.org/web/policies/terms.html">
					Terms
				</a>
			</p>
		</div>
	</body>
</html>
<!-- /FOOTER -->
