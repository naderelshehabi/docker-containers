import jenkins.model.Jenkins
import jenkins.model.JenkinsLocationConfiguration
import hudson.plugins.locale.PluginImpl

// println("--- Configuring Server URL")
// def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
// def env = System.getenv()

// set Jenkins URL
// jenkinsLocationConfiguration.setUrl(env['JENKINS_URL'])

// save current Jenkins state to disk
// jenkinsLocationConfiguration.save()

println("--- Configuring Locale")
//TODO: Create ticket to get better API
PluginImpl localePlugin = (PluginImpl)Jenkins.instance.getPlugin("locale")
localePlugin.systemLocale = "en_US"
localePlugin.@ignoreAcceptLanguage=true