package muit.timetable.event
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import muit.timetable.model.Reserve;
	import muit.timetable.parts.ReserveBox;
	
	public class TimetableEvent extends Event
	{
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// Constant Variable
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public static const TIME_SELECTED:String = "timeSelected";
		public static const RESERVE_DELETED:String = "reserveDeleted";
		public static const RESERVE_EDIT:String = "reserveEdit";
		public static const RESERVE_MOVED:String = "reserveMoved";
		public static const RESERVE_CHANGED:String = "reserveChanged";

		public static const CAUTION_ALLREADY_RESERVED:String = "cautionAllreadyReserved";
		public static const CAUTION_OVERFLOWED:String = "cautionOverflowed";
		
		public static const DRAGSTART:String = "dragStart";
		public static const RESIZESTART:String = "resizeStart";
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// ACCESSER
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// cellIndexPoint
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _cellIndexPoint:Point = new Point();
		public function get cellIndexPoint():Point
		{
			return _cellIndexPoint;
		}
		public function set cellIndexPoint(value:Point):void
		{
			_cellIndexPoint = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// cellCount
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _cellCount:int;
		public function get cellCount():int
		{
			return _cellCount;
		}
		public function set cellCount(value:int):void
		{
			_cellCount = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// reserve
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		private var _reserve:Reserve;
		public function get reserve():Reserve
		{
			return _reserve;
		}
		public function set reserve(value:Reserve):void
		{
			_reserve = value;
		}
		
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// CONSTRACTOR
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public function TimetableEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}//end of class
}//end of package