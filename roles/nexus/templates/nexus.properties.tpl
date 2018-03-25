# Jetty section
application-port=8081
application-port-ssl=8443
application-host=0.0.0.0
nexus-args=${jetty.etc}/jetty.xml,${jetty.etc}/jetty-http.xml,${jetty.etc}/jetty-https.xml,${jetty.etc}/jetty-requestlog.xml
nexus-context-path=/

# Nexus section
# nexus-edition=nexus-pro-edition
# nexus-features=\
#  nexus-pro-feature