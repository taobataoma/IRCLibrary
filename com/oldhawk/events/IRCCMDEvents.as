package com.oldhawk.events
{
	import flash.events.Event;
		
	public class IRCCMDEvents extends Event
	{
		public static const ONTXTCOMMAND:String			= "onTxtCommand";
		public static const ONNUMCOMMAND:String			= "onNumCommand";
		public static const ONPINGCOMMAND:String		= "onPingCommand";

		public var user:String;
		public var cmd:String;
		public var msg:String;
		
		public function IRCCMDEvents(type:String, user:String = "", cmd:String = "", msg:String = "", bubbles:Boolean = false, cancelable:Boolean = false){
			super(type, bubbles, cancelable);
			this.user = user;
			this.cmd = cmd;
			this.msg = msg;
		}
		
	    override public function clone():Event{
	        return new IRCCMDEvents(type, this.user, this.cmd, this.msg, bubbles, cancelable);
	    }
	}
}