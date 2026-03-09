import { Form, Input, Select, Switch } from 'antd';
import { useState } from 'react';

const LocalFileForm = ({ form }: { form: any }) => {
  const [fileType, setFileType] = useState('directory');

  const generateAutoName = () => {
    const now = new Date();
    const datePart = now.toLocaleDateString('zh-CN').replace(/\//g, '');
    const timePart = now.toTimeString().slice(0, 8).replace(/:/g, '');
    return `local_file_${datePart}_${timePart}`;
  };

  return (
    <div style={{ padding: '0 16px' }}>
      <Form
        form={form}
        labelCol={{ span: 3 }}
        wrapperCol={{ span: 19 }}
        initialValues={{
          fileType: 'directory',
          recursive: true,
          environmentId: 1,
          alias: generateAutoName(),
        }}
        style={{ marginTop: 18 }}
      >
        <Form.Item
          label={<div style={{ height: 32, lineHeight: '33px' }}>数据源名称</div>}
          name="alias"
          rules={[{ required: true, message: '数据源名称不能为空' }]}
        >
          <Input 
            placeholder="输入数据源名称"
            maxLength={100} 
            size="small" 
          />
        </Form.Item>

        <Form.Item
          label={<div style={{ height: 32, lineHeight: '33px' }}>所属环境</div>}
          name="environmentId"
          rules={[{ required: true, message: '所属环境不能为空' }]}
        >
          <Select
            placeholder="选择所属环境"
            size="small"
            options={[
              { label: '开发环境', value: 1 },
              { label: '测试环境', value: 2 },
              { label: '生产环境', value: 3 },
            ]}
          />
        </Form.Item>

        <Form.Item
          label={<div style={{ height: 32, lineHeight: '33px' }}>文件类型</div>}
          name="fileType"
          rules={[{ required: true, message: '文件类型不能为空' }]}
        >
          <Select
            placeholder="选择文件类型"
            size="small"
            onChange={(value) => setFileType(value)}
            options={[
              { label: '目录', value: 'directory' },
              { label: '文件', value: 'file' },
            ]}
          />
        </Form.Item>

        <Form.Item
          label={<div style={{ height: 32, lineHeight: '33px' }}>文件路径</div>}
          name="path"
          rules={[{ required: true, message: '文件路径不能为空' }]}
        >
          <Input 
            placeholder="输入文件或目录路径，如：/home/user/data/"
            size="small" 
          />
        </Form.Item>

        {fileType === 'directory' && (
          <Form.Item
            label={<div style={{ height: 32, lineHeight: '33px' }}>递归扫描</div>}
            name="recursive"
            valuePropName="checked"
          >
            <Switch 
              size="small" 
              checkedChildren="开启"
              unCheckedChildren="关闭"
            />
          </Form.Item>
        )}

        <Form.Item
          label={<div style={{ height: 32, lineHeight: '33px' }}>文件匹配模式</div>}
          name="filePattern"
        >
          <Input 
            placeholder="文件名匹配模式，如：*.csv, *.txt"
            size="small" 
          />
        </Form.Item>

        <Form.Item
          label={<div style={{ height: 32, lineHeight: '33px' }}>文件编码</div>}
          name="encoding"
          initialValue="UTF-8"
        >
          <Select
            placeholder="选择文件编码"
            size="small"
            options={[
              { label: 'UTF-8', value: 'UTF-8' },
              { label: 'GBK', value: 'GBK' },
              { label: 'GB2312', value: 'GB2312' },
              { label: 'ISO-8859-1', value: 'ISO-8859-1' },
            ]}
          />
        </Form.Item>

        <Form.Item
          label={<div style={{ height: 32, lineHeight: '33px' }}>分隔符</div>}
          name="delimiter"
        >
          <Input 
            placeholder="CSV文件分隔符，默认为逗号"
            size="small" 
            maxLength={1}
          />
        </Form.Item>

        <Form.Item
          label={<div style={{ height: 32, lineHeight: '33px' }}>描述信息</div>}
          name="description"
        >
          <Input.TextArea 
            placeholder="输入数据源描述信息"
            size="small" 
            rows={3}
          />
        </Form.Item>
      </Form>
    </div>
  );
};

export default LocalFileForm;