package muit.timetable.util
{
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	
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
		
		public static function sortByDate(days:ArrayCollection):ArrayCollection
		{
			var ret:ArrayCollection = new ArrayCollection();
			
			var times:ArrayCollection = new ArrayCollection();
			var dl:int = days.length;

			for(var i:int=0; i<dl; i++)
			{
				var d:Date = days.getItemAt(i) as Date;
				times.addItem(d.getTime());
			}
			
			var sort:Sort = new Sort();
			sort.fields = [new SortField(null, true)];
			times.sort = sort;
			times.refresh();
			
			var tl:int = times.length;
			for(var t:int=0; t<tl; t++)
			{
				var newdate:Date = new Date();
				newdate.setTime(times.getItemAt(t));
				ret.addItem(newdate);
			}
			
			return ret;
		}
		
		public static function removeDuplication(days:ArrayCollection):ArrayCollection
		{
			var ret:ArrayCollection = new ArrayCollection();
			var pre:Number = 0;
			var dl:int = days.length;
			for(var i:int=0; i<dl; i++)
			{
				var d:Date = days.getItemAt(i) as Date;
				var t:Number = DateUtil.getDayTime(d);
				
				if(pre == 0)
				{
					ret.addItem(d);
					pre = t;
				}
				else
				{
					if(pre != t)
					{
						ret.addItem(d);
						pre = t;
					}
					else
					{
						//do nothing
					}
				}
			}
			
			return ret;
		}
		
	}//end of class
}//end of package