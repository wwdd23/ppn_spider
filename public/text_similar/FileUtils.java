/**
 * Project Name:GitHub
 * Date:2015年7月4日下午10:38:21
 * Copyright (c) 2015, Business-intelligence of Oriental Nations Corporation Ltd. All Rights Reserved.
 *
 */

package cn.fishtrip;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.swing.plaf.basic.BasicScrollPaneUI.HSBChangeListener;

/**
 * ClassName: ReadFileUtils <br/>
 * Function: TODO ADD FUNCTION. <br/>
 * Reason: TODO ADD REASON(可选). <br/>
 * date: 2015年7月4日 下午10:38:21 <br/>
 *
 * @author weidongfang
 * @version 1.0
 */
public class FileUtils {
    public static List<String> readFile(String fileName){
        List<String> list = new ArrayList<String>();
        BufferedReader br = null;
        try {
            br=new BufferedReader(new InputStreamReader(new FileInputStream(fileName),"UTF-8")); 
           
            String line = null;
            while ((line = br.readLine()) != null) {
                if(!line.trim().isEmpty()){
                    list.add(line);
                }
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        }finally{
            try {
                br.close();
            } catch (IOException e) {
                
                e.printStackTrace();
                
            }
        }
       
        return list;
    }

    
    
    public  static  void writeFile(HashMap<String, List<String>> hashMap, String resultPath) throws IOException{
        FileWriter writer = new FileWriter(resultPath);
        Iterator<Entry<String, List<String>>> iterator =  hashMap.entrySet().iterator();
        while (iterator.hasNext()){
           Entry<String, List<String>> entry =  iterator.next();
           String key = entry.getKey();
           List<String> list = entry.getValue();
           for(String str : list){
               writer.write(key + "\t" + str + "\n");
           }
        }
        writer.flush();
        writer.close();
    }
}

