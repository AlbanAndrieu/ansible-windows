# escape=`
ARG BASE_TAG=1803
#ARG BASE_TAG=ltsc2019

#FROM mcr.microsoft.com/windows/servercore:$BASE_TAG as builder
FROM mback2k/windows-buildbot-tools:latest_1803 as builder

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
USER ContainerAdministrator

ENV JAVA_HOME C:\Tools\Java
ENV JAVA_BINARY jdk-8u261-windows-x64.exe
ENV ZIP_HOME C:\Tools\7-zip
ENV ZIP_BINARY 7z1900-x64.exe

ADD https://www.7-zip.org/a/$ZIP_BINARY C:\$ZIP_BINARY
RUN Start-Process -Wait -passthru -FilePath $('C:\{0}' -f $env:ZIP_BINARY) -argumentlist ('/S /D=\"{0}\"' -f $env:ZIP_HOME)
RUN SetX PATH "\"${env:ZIP_HOME};%PATH%\""
RUN Remove-Item -Force $('C:\{0}' -f $env:ZIP_BINARY)

ADD https://javadl.oracle.com/webapps/download/GetFile/1.8.0_261-b12/a4634525489241b9a9e1aa73d9e118e6/windows-i586/$JAVA_BINARY C:\$JAVA_BINARY
RUN start-process -filepath $('C:\{0}' -f $env:JAVA_BINARY) -passthru -wait -argumentlist "\"/s INSTALLDIR=${env:JAVA_HOME} /L C:\Tools\install_java64.log\""
RUN del $('C:\{0}' -f $env:JAVA_BINARY)
RUN SetX PATH "\"${env:JAVA_HOME}\bin;%PATH%\""

#FROM mcr.microsoft.com/powershell:preview-nanoserver-$BASE_TAG
FROM mcr.microsoft.com/windows/servercore:$BASE_TAG as runtime
SHELL ["pwsh.exe", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
USER ContainerAdministrator
ARG user=jenkins
#RUN net accounts /maxpwage:unlimited ; `
#    net user "$env:user" /add /expire:never /passwordreq:no ; `
#    net localgroup Administrators /add $env:user ; `
#    New-Item -ItemType Directory -Path C:/ProgramData/Jenkins | Out-Null

ARG JAVA_HOME=C:\Tools\Java
ENV WindowsPATH="C:\Windows\system32;C:\Windows"
COPY --from=builder ["$JAVA_HOME", "$JAVA_HOME"]
COPY --from=builder ["C:/Tools/7-zip", "C:/Tools/7-zip"]

#COPY misyscert-old.crt /Certs/
#COPY misyscert-2016.crt /Certs/
#COPY finastra-CA.crt /Certs/

WORKDIR $JAVA_HOME/jre/lib/security

#RUN ..\..\bin\keytool.exe -import -trustcacerts -keystore cacerts -storepass changeit -noprompt -alias misys-ca-old -file C:/Certs/misyscert-old.crt
#RUN ..\..\bin\keytool.exe -import -trustcacerts -keystore cacerts -storepass changeit -noprompt -alias misys-2016 -file C:/Certs/misyscert-2016.crt
#RUN ..\..\bin\keytool.exe -import -trustcacerts -keystore cacerts -storepass changeit -noprompt -alias finastra -file C:/Certs/finastra-CA.crt
ENV ProgramFiles="C:\Program Files"
ENV PATH="$WindowsPATH;${JAVA_HOME}\bin;C:\Tools\7-zip;${ProgramFiles}\PowerShell"

ARG AGENT_FILENAME=agent.jar
ARG AGENT_HASH_FILENAME=$AGENT_FILENAME.sha1

ARG VERSION=4.3

ARG AGENT_ROOT=C:/Users/$user
ARG AGENT_WORKDIR=${AGENT_ROOT}/Work

ENV AGENT_WORKDIR=${AGENT_WORKDIR}

# Get the Agent from the Jenkins Artifacts Repository
#RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
#    Invoke-WebRequest $('https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/{0}/remoting-{0}.jar' -f $env:VERSION) -OutFile $(Join-Path C:/ProgramData/Jenkins $env:AGENT_FILENAME) -UseBasicParsing ; `
#    Invoke-WebRequest $('https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/{0}/remoting-{0}.jar.sha1' -f $env:VERSION) -OutFile (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME) -UseBasicParsing ; `
#    if ((Get-FileHash (Join-Path C:/ProgramData/Jenkins $env:AGENT_FILENAME) -Algorithm SHA1).Hash -ne (Get-Content (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME))) {exit 1} ; `
#    Remove-Item -Force (Join-Path C:/ProgramData/Jenkins $env:AGENT_HASH_FILENAME)

#COPY files/jenkins-agent.ps1 C:/ProgramData/Jenkins

#USER jenkins

#RUN New-Item -Type Directory $('{0}/.jenkins' -f $env:AGENT_ROOT) | Out-Null ; `
#    New-Item -Type Directory $env:AGENT_WORKDIR | Out-Null

#VOLUME ${AGENT_ROOT}/.jenkins
VOLUME ${AGENT_WORKDIR}
WORKDIR ${AGENT_ROOT}

USER ContainerAdministrator

#ENTRYPOINT ["pwsh.exe", "-f", "C:/ProgramData/Jenkins/jenkins-agent.ps1"]
