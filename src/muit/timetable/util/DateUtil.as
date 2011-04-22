package muit.timetable.util
{
	import org.hamcrest.mxml.object.Null;

	public class DateUtil
	{
		public function DateUtil()
		{
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// compare
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		public static function date1GreaterThanDate2(date1:Date, date2:Date):Boolean
		{
			var d1:Number = DateUtil.getDayTime(date1);
			var d2:Number = DateUtil.getDayTime(date2);
			
			if( d1 > d2)
			{
				return true;
			}
			else
			{
				return false;
			}
		}//end of method
		
		public static function date1LessThanDate2(date1:Date, date2:Date):Boolean
		{
			var d1:Number = DateUtil.getDayTime(date1);
			var d2:Number = DateUtil.getDayTime(date2);
			
			if( d1 < d2)
			{
				return true;
			}
			else
			{
				return false;
			}
		}//end of method
		
		public static function date1GreaterThanOrEqualDate2(date1:Date, date2:Date):Boolean
		{
			var d1:Number = DateUtil.getDayTime(date1);
			var d2:Number = DateUtil.getDayTime(date2);
			
			if( d1 >= d2)
			{
				return true;
			}
			else
			{
				return false;
			}
		}//end of method
		
		public static function date1LessThanOrEqualDate2(date1:Date, date2:Date):Boolean
		{
			var d1:Number = DateUtil.getDayTime(date1);
			var d2:Number = DateUtil.getDayTime(date2);
			
			if( d1 <= d2)
			{
				return true;
			}
			else
			{
				return false;
			}
		}//end of method
		
		public static function equal(date1:Date, date2:Date):Boolean
		{
			var d1:Number = DateUtil.getDayTime(date1);
			var d2:Number = DateUtil.getDayTime(date2);
			
			if( d1 == d2)
			{
				return true;
			}
			else
			{
				return false;
			}
		}//end of method

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// calculate
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		public static function plusDay(target:Date, plus:int):Date
		{
			var ret:Date = new Date();
			ret.setTime(target.getTime() + plus * 24 * 60 * 60 * 1000);
			return ret;
		}

		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		// util
		//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
		
		public static function getDaysLength(startDate:Date, endDate:Date):Number
		{
			var s:Number = startDate.getTime();
			var e:Number = endDate.getTime();
			var ret:Number = (e - s) / 1000 / 60 / 60 / 24;
			return ret + 1;
		}
		
		
		public static function getDayTime(target:Date):Number
		{
			var tmp:Date = new Date(target.getFullYear(), target.getMonth(), target.getDate());
			return tmp.getTime();
		}
		
		public static function be2char(target:String):String
		{
			if(target.length == 1)
			{
				return "0" + target;
			}
			
			return target;
		}
		
	}//end of class
}//end of package