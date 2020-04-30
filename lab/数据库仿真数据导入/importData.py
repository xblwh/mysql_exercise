#coding=utf-8

from xlrd import *
from pymysql import *   #pymysql只支持python2
import datetime
import sys


# tool function
def GetStationID( SName ):  
  cursor.execute("select SID from Station where SName = %s", SName)
  return cursor.fetchone()[0]


def GetTrainID( TName ):
  cursor.execute("select TID from Train where TName = %s", TName)
  rows = cursor.fetchall()
  records = []
  for r in rows:
    records.append(r[0])
  return records


def GetTrainSDateTime( tid ):
  cursor.execute('select SDateTime from Train where TID = %s', tid)
  return cursor.fetchone()[0].strftime("%Y-%m-%d")   #去掉时分秒同时datetime类型变为str类型, datetime与date是2种不同类型


def insertCommond( fileName, sheetInfo ):
  if fileName == "./旅客表仿真数据.xls":
    cursor.executemany('insert into Passenger(PName, Sex, PCardID, Age) values(%s, %s, %s, %s)', sheetInfo )
  elif fileName == "./部分车次的运行时刻表.xls":
    cursor.executemany('insert into TrainPass(TID, SNo, SID, ADateTime, LDateTime) values(%s, %s, %s, %s, %s)', sheetInfo )
  elif fileName == "./部分车次.xls":
    cursor.executemany('insert into Train(SDate, TName, SStationID, AStationID, SDateTime, ADateTime) values(%s, %s, %s, %s, %s, %s)', sheetInfo ) 
  elif fileName == "./全国车站表.xls":
    cursor.executemany('insert into Station(SID, SName, CityName) values(%s, %s, %s)', sheetInfo )



# 旅客表
def PassengerFormat( sheet, i ):
  try:
    PName = sheet.cell_value(i,0).strip()
    # print( sheet.cell_value(i,1) )    # 0.0 / 1.0, return float type
    Sex = int(sheet.cell_value(i,1))
    PCardID = sheet.cell_value(i,2).strip()
    Age = int(sheet.cell_value(i,3))
    return (PName, Sex, PCardID, Age)

  except Exception, err:
      print(err)
      print(sheet.cell_value(i,1))
      sys.exit(1)


# 车站表
def StationFormat( sheet, i ):
    SID = int(sheet.cell_value(i,0))
    SName = sheet.cell_value(i,1).strip()
    CityName = sheet.cell_value(i,2).strip()
    return (SID, SName, CityName)

# 部分车次表
def TrainFormat( sheet, i ):
    #TID auto increase in mysql
    TName = sheet.cell_value(i, 0).strip()
    SStationID = GetStationID( sheet.cell_value(i,1).strip() )
    AStationID = GetStationID( sheet.cell_value(i,2).strip() )

    # (year, month, day, hour, minute, nearest_second)
    STime = xldate_as_tuple( sheet.cell_value(i,3), 0 )
    ATime = xldate_as_tuple( sheet.cell_value(i,4), 0 )
    cost = int(sheet.cell_value(i,5))

    # 生成每一辆列车在 2019-12-01到2020-3-01 的记录
    records = []
    startDate = datetime.datetime.strptime('2019-12-01', "%Y-%m-%d")
    endDate = datetime.datetime.strptime('2020-3-01', "%Y-%m-%d")
    curDate = startDate

    while curDate < endDate:
      curDate += datetime.timedelta( days=1 )
      SDateTime = curDate + datetime.timedelta(hours=STime[3]) + datetime.timedelta(minutes=STime[4])
      ADateTime = curDate + datetime.timedelta( days=(cost-1) ) + datetime.timedelta(hours=ATime[3]) + datetime.timedelta(minutes=ATime[4])

      records.append( (curDate.strftime('%Y-%m-%d'), TName, SStationID, AStationID, 
        SDateTime.strftime('%Y-%m-%d %H:%M:%S'),  ADateTime.strftime('%Y-%m-%d %H:%M:%S'))  )

    return records


# 部分车次的运行时刻表
def TrainPassFormat( sheet, i ):
    TName = sheet.cell_value(i,0).strip().split('/')[0]   #为了简化，只导入一个车次
    SNo = int( sheet.cell_value(i,1) )
    SName = sheet.cell_value(i,2).strip()
    SID = GetStationID( SName )

    accessTime = sheet.cell_value(i,3)
    ATime = None if accessTime == "" else xldate_as_tuple(accessTime, 0)
    leaveTime = sheet.cell_value(i,4)
    LTime = None if leaveTime == "" else xldate_as_tuple(leaveTime, 0)  
    cost = int( sheet.cell_value(i,6) )
    # print( TName, " ", ATime, LTime )

    records = []
    TIDs = GetTrainID(TName)
    for TID in TIDs:
      # print(  type( GetTrainSDateTime( TID ) ) )  
      curDate = datetime.datetime.strptime( GetTrainSDateTime(TID), "%Y-%m-%d") + datetime.timedelta( days=(cost-1) )
      ADateTime = None if ATime == None else ( curDate + datetime.timedelta( hours=ATime[3] ) 
        + datetime.timedelta( minutes=ATime[4] ) + datetime.timedelta( seconds=ATime[5] )  ).strftime("%Y-%m-%d %H:%M:%S")
      # if ATime is not None: print( curDate, ATime[3], ATime[4], ATime[5], ADateTime  )
      LDateTime = None if LTime == None else ( curDate + datetime.timedelta( hours=LTime[3] ) 
        + datetime.timedelta( minutes=LTime[4] ) + datetime.timedelta( seconds=LTime[5] ) ).strftime("%Y-%m-%d %H:%M:%S")
      records.append( (TID, SNo, SID, ADateTime, LDateTime) )

    return records


def GetSheetInfo( sheet , format_fun ):
  talRows = sheet.nrows
  result = []

  for i in range(1,talRows):
    records = format_fun(sheet, i)
    if isinstance(records, list):
      for record in records:
        result.append(record)
    else:
      result.append( records )

  return result





# import data of xml to mySQL
def main():
  fileName = [ "./旅客表仿真数据.xls",
               "./全国车站表.xls",
               "./部分车次.xls",
               "./部分车次的运行时刻表.xls"
               ]    #对于创建表的顺序是有要求的，如 全国车站表 必须在 部分车次表 之前创建

  formats = {"./旅客表仿真数据.xls" : PassengerFormat, 
             "./部分车次的运行时刻表.xls" : TrainPassFormat, 
             "./部分车次.xls" : TrainFormat, 
             "./全国车站表.xls" : StationFormat}
  
  for i in range(len(fileName)):
    print( "{0} import datas from {1}".format( i, fileName[i] ) )
    book = open_workbook(fileName[i].decode('utf-8'))
    if formats.has_key( fileName[i] ):
      sheetInfo = GetSheetInfo(book.sheets()[0], formats[fileName[i]] )
      insertCommond( fileName[i], sheetInfo )   #import datas

  conn.commit()
  conn.close()

  print("import data successfully.")




# running
conn = connect( host='localhost', port=3306, database='lds714610',
  user='root', charset='utf8')
cursor = conn.cursor()
main()