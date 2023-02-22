const path = require('path');
const glob = require('glob');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
const TerserPlugin = require('terser-webpack-plugin');

module.exports = (env, options) => {
  const devMode = options.mode !== 'production';


  return {
    optimization: {
      minimize: true,
      minimizer: [new TerserPlugin()],
    },
    entry: {
      'be_app': glob.sync('./vendor/**/*.js').concat(['./js/be_app.js'])
    },
    output: {
      clean: true,
      filename: '[name].js',
      chunkFilename: "[id].[contenthash].js",
      path: path.resolve(__dirname, '../priv/static/be_js'),
      publicPath: '/be_js/'
    },
    devtool: devMode ? 'eval-cheap-module-source-map' : undefined,
    module: {
      rules: [{
          test: /\.(js|jsx)$/,
          exclude: /node_modules/,
          use: {
            loader: 'babel-loader'
          }
        },
        {
          test: /\.[s]?css$/,
          use: [
            MiniCssExtractPlugin.loader,
            'css-loader',
            // 'postcss-loader',
            // 'sass-loader'
          ],
        }
      ]
    },
    resolve: {
      extensions: ['*', '.js', '.jsx'],
      alias: {
        react: path.resolve(__dirname, './node_modules/react'),
        'react-dom': path.resolve(__dirname, './node_modules/react-dom')
      }
    },
    plugins: [
      new MiniCssExtractPlugin({
        filename: devMode ? '../be_css/be_app_js_dev.css' : '../be_css/be_app_js.css'
      })

    ]
  }
};
