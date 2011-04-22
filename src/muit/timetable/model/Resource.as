package muit.timetable.model
{
	public class Resource
	{
		public function Resource()
		{
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// ACCESSOR
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// resourceID
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _resourceID:String = "";
		public function get resourceID():String
		{
			return _resourceID;
		}
		public function set resourceID(value:String):void
		{
			_resourceID = value;
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// resourceName
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _resourceName:String = "";
		public function get resourceName():String
		{
			return _resourceName;
		}
		public function set resourceName(value:String):void
		{
			_resourceName = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// resourceProps
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _resourceProps:Array = new Array();
		public function get resourceProps():Array
		{
			return _resourceProps;
		}
		public function set resourceProps(value:Array):void
		{
			_resourceProps = value;
		}


		
	}//end of class
}//end of package