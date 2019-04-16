function SendMessageFromMatlab(textmsg)
IP = '130.89.13.1';
port = 80;
tcpipClient = tcpip(IP,port,'NetworkRole','Client');
set(tcpipClient,'Timeout',30);
fopen(tcpipClient);
fwrite(tcpipClient,textmsg);
fclose(tcpipClient);
