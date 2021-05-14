/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * Generated with the TypeScript template
 * https://github.com/react-native-community/react-native-template-typescript
 *
 *
 */

 import React, { useState } from 'react';
 import {
   Button,
   StyleSheet,
   Text,
   TextInput,
   View,
 } from 'react-native';


 import { REACT_NATIVE_SERVER_ADDRESS } from '@env'



 const App = () => {
  const [text,setText] = useState("");

  const  fetchMP3 = async () => {
  
  };

  const playMusic = () => {
  }

  const pauseMusic = () => {
  }

  return (
    <View style={styles.container}>
      <Text>{ REACT_NATIVE_SERVER_ADDRESS +" lol +hi"}</Text>
      <TextInput placeholder="Enter music video" style={styles.textInput} value={text} onChangeText={(e) => setText(e)}></TextInput>
      <View style={styles.buttonView} > 
      <Button title={"Get mp3"} onPress={fetchMP3} />
      </View>
      <View style={styles.buttonView} > 

      <Button title={"Play"} onPress={playMusic}/>
      </View>

      <View style={styles.buttonView} > 

      <Button title={"Stop"} onPress={pauseMusic}/>
      </View>

    </View>
  );
 };

 const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
  textInput: {
    height:20,
    width:"80%",
    borderWidth:1,
  },
  buttonView :{
    padding:5,
  }
});


 export default App;
