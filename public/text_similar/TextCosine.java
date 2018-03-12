/**
 * Project Name:text
 * Date:2015年8月21日下午2:18:22
 * Copyright (c) 2015, Business-intelligence of Oriental Nations Corporation Ltd. All Rights Reserved.
 *
 */

package cn.fishtrip;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

/**
 * ClassName: TextCosine <br/>
 * Function: TODO ADD FUNCTION. <br/>
 * Reason: TODO ADD REASON(可选). <br/>
 * date: 2015年8月21日 下午2:18:22 <br/>
 *
 * @author weidongfang
 * @version 1.0
 */
public class TextCosine {
    
    public static HashMap<String, List<String>> getResult(List<String> TextList1, List<String> TextList2, double similarity){
        HashMap<String, List<String>> hashMap = new HashMap<String, List<String>>();
        List<String> tmp = null;
        for (String text1 : TextList1){
            for(String text2 : TextList2){
                try {
                    double simlarNum = CosineSimilarAlgorithm.getSimilarity(text1, text2);
                    if (simlarNum > 0.60){
                        if(hashMap.containsKey(text1)){
                            hashMap.get(text2).add(text2);
                        }else{
                            tmp = new ArrayList<String>();
                            tmp.add(text2);
                            hashMap.put(text1, tmp);
                        }
                    }
                } catch (Exception e) {
                }
            }
        }
        return hashMap;
    }
    
    
    public static void main(String[] args) throws IOException {
        
        if (args.length < 3){
            System.out.println("use : java -jar Similar.jar doc1, doc2, result.txt, Similarity");
            System.out.println("doc1, doc2 : 为要匹配的两个文文件.");
            System.out.println("result.txt : 结果文件路文件。");
            System.out.println("Similarity : 相似度范围0~1 默认值为 0.75");
            System.out.println("example : java -jar Similar.jar one.txt, two.txt, result.txt, 0.75");
            System.exit(0);
        }
        List<String> TextList1 = FileUtils.readFile(args[0]);
        List<String> TextList2 = FileUtils.readFile(args[1]); 
        double similarity = 0.75 ;
        if(args.length == 4 ){
            similarity = Double.parseDouble(args[3]);
        }
        HashMap<String, List<String>> hashMap= getResult(TextList1, TextList2, similarity);
        FileUtils.writeFile(hashMap, args[2]);
    }
}

