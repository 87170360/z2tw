/*
	需求：有一堆lua文件中包含了简体中文，需要替换成繁体中文。
	实现逻辑
	1. 加载和写入文件
	2. 文字替换，包含按字替换和特定词组替换
	3. 遍历文件目录
	4. 根据需要创建文件目录
*/

package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"

	"github.com/stevenyao/go-opencc"
)

const (
	config_s2tw = "/usr/share/opencc/s2tw.json"
	inputDir    = "input"
	outputDir   = "output"
)

var (
	replace_text = map[string]string{
		"大陆":   "港台",
		"充值":   "儲值",
		"首充":   "首儲",
		"累充":   "累储",
		"服务器":  "伺服器",
		"信息":   "訊息",
		"登陆":   "登入",
		"网络":   "網路",
		"邮箱":   "信箱",
		"反馈":   "回報",
		"好礼":   "好康",
		"福利":   "好康",
		"加载":   "載入",
		"停机更新": "停机维护",
		"更新内容": "维护内容",
	}
)

//根据特定词组替换
func replaceWord(in string) (out string) {
	out = in
	for k, v := range replace_text {
		out = strings.Replace(out, k, v, -1)
	}
	return out
}

//内容转换
func converFile(in, out string) {
	c := opencc.NewConverter(config_s2tw)
	defer c.Close()

	//读取文件
	data, err := ioutil.ReadFile(in)
	if err != nil {
		fmt.Println(err)
	}
	content := fmt.Sprintf("%s", data)
	//替换特定词组
	content = replaceWord(content)
	//替换字
	output := c.Convert(content)
	//写入文件
	writedata := []byte(output)
	err = ioutil.WriteFile(out, writedata, 0666)
	if err != nil {
		fmt.Println(err)
	}
}

// input/xxx/../*.lua -> output/xxx/../*.lua
//创建目录，并返回修改后文件路径
func createOutputDir(in string) (out string) {
	//文件名
	base := filepath.Base(in)
	//组装新文件的路径
	str := strings.TrimPrefix(in, inputDir)
	pure := strings.TrimSuffix(str, base)
	np := fmt.Sprintf("%s%s", outputDir, pure)
	//创建新路径的文件目录
	createDir(np)
	//新文件名
	out = fmt.Sprintf("%s%s", np, base)
	return
}

//创建目录
func createDir(dir string) {
	if _, err := os.Stat(dir); os.IsNotExist(err) {
		os.MkdirAll(dir, os.ModePerm)
	}
}

func main() {
	fileList := []string{}
	err := filepath.Walk(inputDir, func(path string, f os.FileInfo, err error) error {
		//只处理lua文件
		if strings.HasSuffix(path, ".lua") {
			fileList = append(fileList, path)
		}
		return nil
	})

	if err != nil {
		fmt.Println(err)
	}

	for _, file := range fileList {
		//fmt.Println(file)
		out := createOutputDir(file)
		converFile(file, out)
	}
}