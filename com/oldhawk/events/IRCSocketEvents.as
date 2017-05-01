package com.oldhawk.events
{
	import flash.events.Event;
		
	public class IRCSocketEvents extends Event
	{
		public static const ONCONNECT:String		= "onConnect";
		public static const ONCLOSE:String			= "onClose";
		public static const ONSECURITYERROR:String	= "onSecurityError";
		public static const ONIOERROR:String		= "onIoError";
		public static const ONDEBUGSENDMSG:String	= "onDebugSendMsg";
		public static const ONDEBUGRECVMSG:String	= "onDebugRecvMsg";
		public static const ONDEBUGSTATMSG:String	= "onDebugStatMsg";

		public var msg:String;
		
		public function IRCSocketEvents(type:String, msg:String = "", bubbles:Boolean = false, cancelable:Boolean = false){
			super(type, bubbles, cancelable);
			this.msg = msg;
		}
		
	    override public function clone():Event{
	        return new IRCSocketEvents(type, this.msg, bubbles, cancelable);
	    }
	}
}