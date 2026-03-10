import { Form, Input, InputNumber, Select, Switch } from "antd";
import React, { useEffect, useState } from "react";

interface SFTPFormProps {
  form: any;
}

const SFTPForm: React.FC<SFTPFormProps> = ({ form }) => {
  const [authMethod, setAuthMethod] = useState<'password' | 'key'>('password');

  useEffect(() => {
    // 设置默认值
    form.setFieldsValue({
      port: 22,
      timeout: 30,
      fileMode: 'BINARY'
    });
  }, [form]);

  return (
    <div style={{ padding: "0 16px" }}>
      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            数据源名称
          </div>
        }
        name="dbName"
        rules={[
          {
            required: true,
            message: "请输入数据源名称",
          },
        ]}
      >
        <Input
          placeholder="请输入数据源名称"
          maxLength={100}
          size="small"
        />
      </Form.Item>

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            环境
          </div>
        }
        name="environment"
        rules={[
          {
            required: true,
            message: "请选择环境",
          },
        ]}
      >
        <Select
          placeholder="请选择环境"
          size="small"
          options={[
            { label: "DEVELOP", value: "DEVELOP" },
            { label: "TEST", value: "TEST" },
            { label: "PROD", value: "PROD" },
          ]}
        />
      </Form.Item>

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            描述
          </div>
        }
        name="remark"
      >
        <Input.TextArea
          placeholder="请输入描述信息"
          size="small"
          rows={4}
        />
      </Form.Item>

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            主机地址
          </div>
        }
        name="host"
        rules={[
          {
            required: true,
            message: "请输入主机地址",
          },
        ]}
      >
        <Input
          placeholder="如: 192.168.1.100 或 example.com"
          size="small"
        />
      </Form.Item>

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            端口
          </div>
        }
        name="port"
        rules={[
          {
            required: true,
            message: "请输入端口号",
          },
        ]}
      >
        <InputNumber
          placeholder="默认: 22"
          min={1}
          max={65535}
          size="small"
          style={{ width: "100%" }}
        />
      </Form.Item>

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            用户名
          </div>
        }
        name="user"
        rules={[
          {
            required: true,
            message: "请输入用户名",
          },
        ]}
      >
        <Input
          placeholder="如: sftpuser"
          size="small"
        />
      </Form.Item>

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            认证方式
          </div>
        }
        name="authMethod"
        initialValue="password"
      >
        <Select
          placeholder="选择认证方式"
          size="small"
          onChange={(value) => setAuthMethod(value)}
          options={[
            { label: "密码认证", value: "password" },
            { label: "密钥认证", value: "key" },
          ]}
        />
      </Form.Item>

      {authMethod === 'password' && (
        <Form.Item
          label={
            <div style={{ height: 32, lineHeight: "33px" }}>
              密码
            </div>
          }
          name="password"
          rules={[
            {
              required: true,
              message: "请输入密码",
            },
          ]}
        >
          <Input.Password
            placeholder="请输入密码"
            size="small"
          />
        </Form.Item>
      )}

      {authMethod === 'key' && (
        <>
          <Form.Item
            label={
              <div style={{ height: 32, lineHeight: "33px" }}>
                私钥文件路径
              </div>
            }
            name="privateKeyPath"
            rules={[
              {
                required: true,
                message: "请输入私钥文件路径",
              },
            ]}
          >
            <Input
              placeholder="如: ~/.ssh/id_rsa"
              size="small"
            />
          </Form.Item>

          <Form.Item
            label={
              <div style={{ height: 32, lineHeight: "33px" }}>
                私钥密码
              </div>
            }
            name="privateKeyPassphrase"
          >
            <Input.Password
              placeholder="私钥文件的密码（如果有的话）"
              size="small"
            />
          </Form.Item>
        </>
      )}

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            远程目录
          </div>
        }
        name="remotePath"
        rules={[
          {
            required: true,
            message: "请输入远程目录",
          },
        ]}
      >
        <Input
          placeholder="如: /home/user/files"
          size="small"
        />
      </Form.Item>

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            文件模式
          </div>
        }
        name="fileMode"
        initialValue="BINARY"
      >
        <Select
          placeholder="选择文件传输模式"
          size="small"
          options={[
            { label: "二进制模式", value: "BINARY" },
            { label: "文本模式", value: "ASCII" },
          ]}
        />
      </Form.Item>

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            连接超时(秒)
          </div>
        }
        name="timeout"
        initialValue={30}
      >
        <InputNumber
          placeholder="默认: 30"
          min={1}
          max={300}
          size="small"
          style={{ width: "100%" }}
        />
      </Form.Item>

      <Form.Item
        label={
          <div style={{ height: 32, lineHeight: "33px" }}>
            严格主机密钥检查
          </div>
        }
        name="strictHostKeyChecking"
        initialValue={false}
        valuePropName="checked"
      >
        <Switch
          size="small"
          checkedChildren="开启"
          unCheckedChildren="关闭"
        />
      </Form.Item>
    </div>
  );
};

export default SFTPForm;