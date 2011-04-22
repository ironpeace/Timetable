package muit.timetable.model
{
	public class Reserve
	{
		public function Reserve()
		{
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// reserveId
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _reserveId:String = "";
		public function get reserveId():String
		{
			return _reserveId;
		}
		public function set reserveId(value:String):void
		{
			_reserveId = value;
		}
		
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// reserverId
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _reserverId:String = "";
		public function get reserverId():String
		{
			return _reserverId;
		}
		public function set reserverId(value:String):void
		{
			_reserverId = value;
		}

		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// reserverName
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _reserverName:String = "";

		public function get reserverName():String
		{
			return _reserverName;
		}
		
		public function set reserverName(value:String):void
		{
			_reserverName = value;
		}
		
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// date
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _date:Date;

		public function get date():Date
		{
			return _date;
		}

		public function set date(value:Date):void
		{
			_date = value;
		}
		
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// startTimeHour
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _startTimeHour:Number;

		public function get startTimeHour():Number
		{
			return _startTimeHour;
		}

		public function set startTimeHour(value:Number):void
		{
			_startTimeHour = value;
		}

		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// startTimeMin
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _startTimeMin:Number;

		public function get startTimeMin():Number
		{
			return _startTimeMin;
		}

		public function set startTimeMin(value:Number):void
		{
			_startTimeMin = value;
		}

		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// endTimeHour
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _endTimeHour:Number;

		public function get endTimeHour():Number
		{
			return _endTimeHour;
		}

		public function set endTimeHour(value:Number):void
		{
			_endTimeHour = value;
		}

		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// endTimeMin
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _endTimeMin:Number;

		public function get endTimeMin():Number
		{
			return _endTimeMin;
		}

		public function set endTimeMin(value:Number):void
		{
			_endTimeMin = value;
		}

		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// resourceID
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _resourceID:String;

		public function get resourceID():String
		{
			return _resourceID;
		}

		public function set resourceID(value:String):void
		{
			_resourceID = value;
		}
		
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// purpose
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _purpose:String = "";
		public function get purpose():String
		{
			return _purpose;
		}
		public function set purpose(value:String):void
		{
			_purpose = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// dept
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _dept:String = "";
		public function get dept():String
		{
			return _dept;
		}
		public function set dept(value:String):void
		{
			_dept = value;
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
		
		
	}//end of class
}//end of package