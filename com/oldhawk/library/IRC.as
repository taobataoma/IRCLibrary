package com.oldhawk.library
{
    import com.oldhawk.events.*;
    
    import flash.display.Sprite;
    import flash.events.*;
    import flash.net.ObjectEncoding;
    import flash.net.Socket;
    import flash.utils.Endian;
	
	public class IRC extends Sprite
	{	
        private var _hostName:String = "localhost";
        private var _port:uint = 7777;
		private var _random:Number=Math.round(Math.random()*(99999-10000))+10000;
        private var _loginNick:String = "guest"+_random.toString();
		private var _loginUser:String = "Guest";
		private var _loginInfo:String = "flex_client";
        private var _loginPass:String = "";
		private var _loginExtendInfo:String = "";

		private var _showDebugMsg:Boolean = false;
		private var _showDebugMsgMore:Boolean = false;
		private var _usePrefixString:Boolean =false;

        private var _socket:Socket;

		private var _prefixString:String="";
		
		public function IRC()
		{
			super();
		}
		/**
		 * 打开服务器连接
		 * 打连接前，请选set HostName与Port值
		 */		
		public function open():void{
			if(this._showDebugMsg)
				this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONDEBUGSTATMSG, "Begin open IRC:"+this._hostName+":"+this._port));
            this._socket = new Socket();
            this._socket.objectEncoding=ObjectEncoding.AMF3;
            //this._socket.endian=Endian.LITTLE_ENDIAN;
            this._socket.endian=Endian.BIG_ENDIAN;
            configureListeners(this._socket);
            this._socket.connect(_hostName, _port);
		}
		public function doIdent():void{
			if(this._showDebugMsg)
				this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONDEBUGSTATMSG, "Begin doIdent:"+_loginNick));
			if(_loginPass!="")
				this.send("PASS "+_loginPass);
			this.send("NICK "+_loginNick);
			this.send("USER " + _loginUser + " " + "localhost localhost :" + _loginInfo);
			if(_loginExtendInfo!="")
				this.send("EXTENDINFO "+_loginExtendInfo);
		}
        /**
         * 向服务器发送字符型数据 
         * @param data
         * 数据内容
         */        
        public function send(data:String):void {
            //this._socket.writeMultiByte(data+"\r\n","utf-8");
            this._socket.writeUTFBytes(data+"\r\n");
            this._socket.flush();

			if(this._showDebugMsg)
	        	this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONDEBUGSENDMSG, data));
        }
        /**
         * 设置服务器主机地址
         * @param hostName
         * 服务器主机地址
         */        
        public function set hostName(hostName:String):void{
        	this._hostName = hostName;
        }
        /**
         * 取回服务器主机地址
         * @return 
         * 服务器主机地址
         */        
        public function get hostName():String{
        	return this._hostName;
        }
		/**
		 * 设置服务器端口 
		 * @param port
		 * 端口号
		 */        
		public function set port(port:uint):void{
			this._port = port;
		}
		/**
		 * 取回服务器端口号 
		 * @return 
		 * 端口号
		 */		
		public function get port():uint{
			return this._port;
		}
		/**
		 * 设置用户登陆时的昵称 
		 * @param loginNick
		 * 昵称,默认值为guest打头后面跟5位随机数字
		 */		
		public function set loginNick(loginNick:String):void{
			this._loginNick = loginNick;
		}
		/**
		 * 取回用户的登陆昵称 
		 * @return 
		 * 昵称
		 */		
		public function get loginNick():String{
			return this._loginNick;
		}
		/**
		 * 设置用户登陆时的备用名
		 * @param loginUser
		 * 备用名,默认值为guest
		 */
		public function set loginUser(loginUser:String):void{
			this._loginUser = loginUser;
		}
		/**
		 * 取回用户的登陆备用名
		 * @return
		 * 备用名
		 */
		public function get loginUser():String{
			return this._loginUser;
		}
		/**
		 * 设置用户登陆标识信息
		 * @param loginInfo
		 * 信息,默认值为flex_client
		 */
		public function set loginInfo(loginInfo:String):void{
			this._loginInfo = loginInfo;
		}
		/**
		 * 取回用户的登陆标识信息
		 * @return
		 * 信息
		 */
		public function get loginInfo():String{
			return this._loginInfo;
		}
		/**
		 * 设置用户登陆时的密码 
		 * @param loginPass
		 * 密码，默认值为null
		 * 注意：并不是所有的系统都需要密码，带有services系统在登陆后再验证密码,
		 * 而在拍卖系统中是登陆前验证密码
		 */		
		public function set loginPass(loginPass:String):void{
			this._loginPass = loginPass;
		}
		/**
		 * 取回用户登陆时的密码 
		 * @return 
		 * 密码
		 */		
		public function get loginPass():String{
			return this._loginPass;
		}

		/**
		 * 设置用户扩展信息
		 * @param extendinfo
		 */
		public function set loginExtendInfo(loginExtendInfo:String):void{
			this._loginExtendInfo = loginExtendInfo;
		}

		/**
		 * 取回用户扩展信息
		 */
		public function get loginExtendInfo():String{
			return this._loginExtendInfo;
		}
		/**
		 * 设置是否显示debug信息
		 * @param show
		 */
		public function set showDebugMsg(show:Boolean):void{
			this._showDebugMsg = show;
		}
		public function set showDebugMsgMore(show:Boolean):void{
			this._showDebugMsgMore = show;
		}

		public function set usePrefixString(usePrefix:Boolean):void{
			this._usePrefixString = usePrefix;
		}
		/******************************************
		 * 		PRIVATE FUNCTION				  *
		 ******************************************
		 */
        private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.CLOSE, closeHandler);
            dispatcher.addEventListener(Event.CONNECT, connectHandler);
            dispatcher.addEventListener(ProgressEvent.SOCKET_DATA, dataHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }
        private function closeHandler(event:Event):void {
            this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONCLOSE));
        }
        private function connectHandler(event:Event):void {
            this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONCONNECT));
        }
        private function dataHandler(event:ProgressEvent):void {
        	//var tmpString:String="";
       		//tmpString=tmpString+_socket.readMultiByte(_socket.bytesAvailable,"utf-8");
       		var tmpString:String=_socket.readUTFBytes(_socket.bytesAvailable);
        	this.analyzeMsg(tmpString);
        }
        private function ioErrorHandler(event:IOErrorEvent):void {
            this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONIOERROR, event.text));
        }
        private function securityErrorHandler(event:SecurityErrorEvent):void {
            this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONSECURITYERROR, event.text));
        }
		private function analyzeMsg(str:String):void{
			//输出debug消息
			if(this._showDebugMsgMore)
				this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONDEBUGRECVMSG, "-bigmsg more-:"+str));

			if(this._usePrefixString) {
				if (this._prefixString != "") {
					str = this._prefixString + str;
					this._prefixString = "";
				}
				var ii:Number = str.lastIndexOf("\r\n");
				if (ii != str.length - 2) {	//没以\r\n结束，需要保留存入后续消息
					this._prefixString = str.substr(ii + 2);
					str = str.substring(0, ii);
				}
			}

			var msgArray:Array = str.split("\r\n");
   			
			for (var i:Number = 0; i<msgArray.length; i++){
				var user:String = "";
				var cmd:String = "";
				var msg:String = "";
				var tmp:String = "";
					
				msg = msgArray[i];
				msgArray[i] = "";	//must, break the die loop
				if(msg == "")
					continue;
				
				//输出debug消息
				if(this._showDebugMsgMore)
					this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONDEBUGRECVMSG, String(i)+"-more-:"+msg));

				//去掉开头的冒号字符
				if(msg.charAt(0) == ":")
					msg = msg.substr(1, msg.length);
				
				//分析第一个参数
				tmp = msg.substr(0, msg.indexOf(" "));
				if(tmp.indexOf(".")>0){	//含有.号，一般为　IRC server 或者 services 的名字				
					user = tmp;
				}else if(tmp.indexOf("!")>0){	//含有!号，一般为用户操作命令
					user = tmp;
				}else if(tmp==_loginNick){
					user = _loginNick;
				}
				if(user!="")	//第一参数已经被使用了，所以截掉
					msg = msg.substr(msg.indexOf(" ")+1,msg.length);
				
				//取出cmd值，并去掉cmd后面紧跟的空格
				if(msg.indexOf(" ")>0){
					cmd = msg.substr(0,msg.indexOf(" "));
					msg = msg.substr(msg.indexOf(" ")+1,msg.length);
				}
				//如果紧根本人昵称，则去掉昵称与后面的空格
				if(Number(cmd)>0 && msg.indexOf(_loginNick)==0)
					msg = msg.substr(_loginNick.length+1,msg.length);
					
				//如果还以= 打头，则去掉, 353消息便是如此
				if(msg.indexOf("= ")==0)
					msg = msg.substr(2,msg.length);
				
				//如果还以冒号打头，则去掉冒号
				if(msg.charAt(0)==":")
					msg = msg.substr(1,msg.length);
					
				//根据命令调用不同的执行函数块
				if(Number(cmd)>0)
					doNumCMD("",cmd,msg);
				else{
					if(cmd.toUpperCase()=="PING")
						doPingCMD(msg);
					else
						doTextCMD(user,cmd,msg);
				}

			}
		}
		private function doNumCMD(user:String, cmd:String, msg:String):void{
			if(this._showDebugMsg)
				this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONDEBUGRECVMSG,"NUMCMD->cmd="+cmd+",msg="+msg));
			if(cmd!="")
				this.dispatchEvent(new IRCCMDEvents(IRCCMDEvents.ONNUMCOMMAND, user, cmd, msg));
		}
		private function doTextCMD(user:String, cmd:String, msg:String):void{
			if(this._showDebugMsg)
		        this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONDEBUGRECVMSG,"TEXTCMD->user="+user+",cmd="+cmd+",msg="+msg));
			if(cmd!="")
	      		this.dispatchEvent(new IRCCMDEvents(IRCCMDEvents.ONTXTCOMMAND, user, cmd, msg));
		}
		private function doPingCMD(msg:String):void{
			if(this._showDebugMsg)
				this.dispatchEvent(new IRCSocketEvents(IRCSocketEvents.ONDEBUGRECVMSG,"PINGCMD->msg="+msg));
			if(msg!="")
	      		this.dispatchEvent(new IRCCMDEvents(IRCCMDEvents.ONPINGCOMMAND, "", "", msg));
		}
	}
}