"use strict";(self.webpackChunkarklight_docs=self.webpackChunkarklight_docs||[]).push([[330],{3905:(e,t,n)=>{n.d(t,{Zo:()=>p,kt:()=>m});var a=n(7294);function r(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function i(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var a=Object.getOwnPropertySymbols(e);t&&(a=a.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,a)}return n}function o(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?i(Object(n),!0).forEach((function(t){r(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):i(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function l(e,t){if(null==e)return{};var n,a,r=function(e,t){if(null==e)return{};var n,a,r={},i=Object.keys(e);for(a=0;a<i.length;a++)n=i[a],t.indexOf(n)>=0||(r[n]=e[n]);return r}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(a=0;a<i.length;a++)n=i[a],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(r[n]=e[n])}return r}var s=a.createContext({}),c=function(e){var t=a.useContext(s),n=t;return e&&(n="function"==typeof e?e(t):o(o({},t),e)),n},p=function(e){var t=c(e.components);return a.createElement(s.Provider,{value:t},e.children)},d="mdxType",u={inlineCode:"code",wrapper:function(e){var t=e.children;return a.createElement(a.Fragment,{},t)}},h=a.forwardRef((function(e,t){var n=e.components,r=e.mdxType,i=e.originalType,s=e.parentName,p=l(e,["components","mdxType","originalType","parentName"]),d=c(n),h=r,m=d["".concat(s,".").concat(h)]||d[h]||u[h]||i;return n?a.createElement(m,o(o({ref:t},p),{},{components:n})):a.createElement(m,o({ref:t},p))}));function m(e,t){var n=arguments,r=t&&t.mdxType;if("string"==typeof e||r){var i=n.length,o=new Array(i);o[0]=h;var l={};for(var s in t)hasOwnProperty.call(t,s)&&(l[s]=t[s]);l.originalType=e,l[d]="string"==typeof e?e:r,o[1]=l;for(var c=2;c<i;c++)o[c]=n[c];return a.createElement.apply(null,o)}return a.createElement.apply(null,n)}h.displayName="MDXCreateElement"},2648:(e,t,n)=>{n.r(t),n.d(t,{assets:()=>s,contentTitle:()=>o,default:()=>u,frontMatter:()=>i,metadata:()=>l,toc:()=>c});var a=n(7462),r=(n(7294),n(3905));const i={sidebar_position:1},o="Data Replication and Events",l={unversionedId:"replication",id:"replication",title:"Data Replication and Events",description:'"What?"',source:"@site/docs/replication.md",sourceDirName:".",slug:"/replication",permalink:"/ProfileSync/docs/replication",draft:!1,editUrl:"https://github.com/nSpected/ProfileSync/docs/replication.md",tags:[],version:"current",sidebarPosition:1,frontMatter:{sidebar_position:1},sidebar:"tutorialSidebar",previous:{title:"\ud83c\udf1f Introduction",permalink:"/ProfileSync/docs/intro"},next:{title:"DataService - Server Functions",permalink:"/ProfileSync/docs/category/dataservice---server-functions"}},s={},c=[{value:"\u2753 &quot;What?&quot;",id:"-what",level:3},{value:"\ud83e\udd14 &quot;Why use ProfileSync when I can request data directly from the server?&quot;",id:"-why-use-profilesync-when-i-can-request-data-directly-from-the-server",level:3},{value:"\ud83e\udd14 &quot;Okay, but what about when a data changes? How can I detect that?&quot;",id:"-okay-but-what-about-when-a-data-changes-how-can-i-detect-that",level:3},{value:"\ud83d\udca1 Possible Use Case",id:"-possible-use-case",level:2},{value:"\ud83d\udd0d Example",id:"-example",level:2},{value:"\ud83c\udf10 Server:",id:"-server",level:3},{value:"\ud83d\udda5\ufe0f Client:",id:"\ufe0f-client",level:3}],p={toc:c},d="wrapper";function u(e){let{components:t,...n}=e;return(0,r.kt)(d,(0,a.Z)({},p,n,{components:t,mdxType:"MDXLayout"}),(0,r.kt)("h1",{id:"data-replication-and-events"},"Data Replication and Events"),(0,r.kt)("h3",{id:"-what"},'\u2753 "What?"'),(0,r.kt)("p",null,(0,r.kt)("strong",{parentName:"p"},"ProfileSync")," handles all data replication for you, streamlining the process. "),(0,r.kt)("h3",{id:"-why-use-profilesync-when-i-can-request-data-directly-from-the-server"},'\ud83e\udd14 "Why use ProfileSync when I can request data directly from the server?"'),(0,r.kt)("p",null,"ProfileSync allows you to simply request the latest data through the DataController. As soon as the data is changed on the server, it's automatically updated on the client side, thanks to a remote event that transmits the most recent updates. This ensures you always have access to up-to-date information without the need for manual requests."),(0,r.kt)("h3",{id:"-okay-but-what-about-when-a-data-changes-how-can-i-detect-that"},'\ud83e\udd14 "Okay, but what about when a data changes? How can I detect that?"'),(0,r.kt)("p",null,"ProfileSync's DataService and DataController both feature a ",(0,r.kt)("inlineCode",{parentName:"p"},'"Changed"')," signal event that triggers whenever data is updated. On the client side, the event passes the arguments ",(0,r.kt)("inlineCode",{parentName:"p"},"(PlayerData: {}, DataName: string)"),", while on the server side, the arguments are ",(0,r.kt)("inlineCode",{parentName:"p"},"(Player: Player, PlayerData: {}, DataName: string)"),". You can connect this signal to a function in any script or local script to monitor changes in real-time."),(0,r.kt)("p",null,"It's important to note that you cannot connect a server script to the client's ",(0,r.kt)("inlineCode",{parentName:"p"},'"Changed"')," event and vice versa. Additionally, the client's ",(0,r.kt)("inlineCode",{parentName:"p"},'"Changed"')," event is fired only for the ",(0,r.kt)("inlineCode",{parentName:"p"},"LocalPlayer")," by default, but you can modify this behavior if needed."),(0,r.kt)("admonition",{title:"Note",type:"caution"},(0,r.kt)("p",{parentName:"admonition"}," No server-client event mixing. Client's ",(0,r.kt)("inlineCode",{parentName:"p"},'"Changed"')," event is for Client ",(0,r.kt)("strong",{parentName:"p"},"ONLY"),".")),(0,r.kt)("h2",{id:"-possible-use-case"},"\ud83d\udca1 Possible Use Case"),(0,r.kt)("p",null,"Imagine you have an ",(0,r.kt)("strong",{parentName:"p"},"inventory panel")," that needs to be updated whenever the player's inventory data changes. With the ",(0,r.kt)("inlineCode",{parentName:"p"},'"Changed"')," event, this is easily achievable! "),(0,r.kt)("p",null,"Just connect to the ",(0,r.kt)("inlineCode",{parentName:"p"},"DataController.Changed")," event, and when it fires, check ",(0,r.kt)("inlineCode",{parentName:"p"},'if DataName == "Inventory"'),". If it does, update the inventory accordingly.\nYou can even use the ",(0,r.kt)("inlineCode",{parentName:"p"},"PlayerData")," argument to access the inventory data or request it using ",(0,r.kt)("inlineCode",{parentName:"p"},'DataController:GetData(Player, "Inventory")')," within your function to refresh the panel."),(0,r.kt)("h2",{id:"-example"},"\ud83d\udd0d Example"),(0,r.kt)("p",null,"In this example, the server adds ",(0,r.kt)("inlineCode",{parentName:"p"},"50 Gems")," to the Player every second. Once the data is replicated, the client prints the updated gem count through the ",(0,r.kt)("inlineCode",{parentName:"p"},".Changed")," signal. Meanwhile, the server logs a warning each time the gem count changes. "),(0,r.kt)("admonition",{title:"Just An Example",type:"caution"},(0,r.kt)("p",{parentName:"admonition"},"Please note that this example won't run in Roblox Studio if you simply paste it there. The example is meant to demonstrate how you can connect the signal to detect changes, but it won't work as-is because the Player object is nil in this context.")),(0,r.kt)("h3",{id:"-server"},"\ud83c\udf10 Server:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'  task.spawn(function()\n    while task.wait(1) do\n      if not DataService.Server_Initialized then return end -- Just to remember to only call service methods after the server has been initialized.\n      DataService:Add(Player, "Gems", 50)\n    end\n  end)\n\n  DataService.Changed:Connect(function(Player : Player, PlayerData : {}, DataName : string)\n    warn(Player, PlayerData[DataName], DataName) -- Output: PlayerName, GemsAmount, "Gems"\n  end)\n')),(0,r.kt)("h3",{id:"\ufe0f-client"},"\ud83d\udda5\ufe0f Client:"),(0,r.kt)("pre",null,(0,r.kt)("code",{parentName:"pre",className:"language-lua"},'  DataController.Changed:Connect(function(PlayerData : {}, DataName : string)\n    print(PlayerData[DataName], DataName) -- Output: GemsAmount, "Gems"\n  end)\n')))}u.isMDXComponent=!0}}]);