<script lang="ts">
	import { onMount, afterUpdate } from 'svelte';
	import api from '$lib/api';
	import type { Message } from '$lib/types/Message';

	let username: string = 'User' + Math.floor(Math.random() * 1000);
	let newMessage: string = '';
	let messages: Message[] = [];
	let chatContainer: HTMLDivElement;
	let selectedFile: File | null = null;
	let fileInput: HTMLInputElement;
	let uploading = false;
	let saveStatus = '';
	let loadChatId = '';

	const scrollToBottom = () => {
		if (chatContainer) {
			chatContainer.scrollTop = chatContainer.scrollHeight;
		}
	};

	const fetchAllMessages = async () => {
		try {
			const response = await api.get('/chat/all', { params: { username } });
			messages = response.data.messages;
			scrollToBottom();
		} catch (error) {
			console.error('Error fetching all messages:', error);
		}
	};

	const fetchNewMessages = async () => {
		try {
			const lastTimestamp = messages.length
				? messages[messages.length - 1].timestamp
				: new Date(0).toISOString();
			const response = await api.get('/chat', {
				params: { username, after: lastTimestamp }
			});
			if (response.data.messages && response.data.messages.length) {
				messages = [...messages, ...response.data.messages];
				scrollToBottom();
			}
		} catch (error) {
			console.error('Error fetching new messages:', error);
		}
	};

	const sendMessage = async () => {
		if (!newMessage.trim() && !selectedFile) return;
		uploading = true;

		try {
			let imageKey: string | undefined = undefined;

			if (selectedFile) {
				const urlResponse = await api.post('/chat/upload-url', {
					filename: selectedFile.name
				});
				const { uploadUrl, key } = urlResponse.data;

				await fetch(uploadUrl, {
					method: 'PUT',
					body: selectedFile,
					headers: { 'Content-Type': selectedFile.type }
				});

				imageKey = key;
			}

			await api.post('/chat', {
				username,
				message: newMessage || (selectedFile ? `[image: ${selectedFile.name}]` : ''),
				imageKey
			});

			newMessage = '';
			selectedFile = null;
			if (fileInput) fileInput.value = '';
			await fetchAllMessages();
			scrollToBottom();
		} catch (error) {
			console.error('Error sending message:', error);
		} finally {
			uploading = false;
		}
	};

	const handleFileSelect = (event: Event) => {
		const target = event.target as HTMLInputElement;
		selectedFile = target.files?.[0] ?? null;
	};

	const clearFile = () => {
		selectedFile = null;
		if (fileInput) fileInput.value = '';
	};

	const saveChat = async () => {
		try {
			saveStatus = 'Saving...';
			const response = await api.post('/chat/history/save');
			saveStatus = `Saved! ID: ${response.data.chatId}`;
			setTimeout(() => (saveStatus = ''), 5000);
		} catch (error) {
			saveStatus = 'Error saving chat';
			console.error('Error saving chat:', error);
		}
	};

	const loadChat = async () => {
		if (!loadChatId.trim()) return;
		try {
			const response = await api.get(`/chat/history/${loadChatId}`);
			messages = response.data.messages;
			scrollToBottom();
		} catch (error) {
			console.error('Error loading chat:', error);
		}
	};

	onMount(() => {
		fetchAllMessages();
		const interval = setInterval(fetchNewMessages, 3000);
		return () => clearInterval(interval);
	});

	afterUpdate(() => {
		scrollToBottom();
	});
</script>

<div class="max-w-2xl mx-auto p-4">
	<div class="mb-4 flex items-center">
		<label for="username" class="font-semibold mr-2">Nickname:</label>
		<input
			id="username"
			type="text"
			autocomplete="off"
			bind:value={username}
			class="border border-gray-300 rounded px-3 py-2"
			placeholder="Enter your nickname"
		/>
	</div>

	<h1 class="text-2xl font-bold mb-4">Chat Room</h1>

	<div class="border border-gray-300 rounded p-4 mb-4 h-80 overflow-y-auto" bind:this={chatContainer}>
		{#each messages as msg (msg.timestamp)}
			<div class="mb-2">
				<span class="font-semibold">{msg.username}</span>
				<span class="text-sm text-gray-500 ml-2">{new Date(msg.timestamp).toLocaleTimeString()}</span>
				<p>{msg.message}</p>
				{#if msg.imageUrl}
					<img
						src={msg.imageUrl}
						alt="attached"
						class="mt-1 max-w-xs max-h-48 rounded border border-gray-200"
					/>
				{/if}
			</div>
		{/each}
	</div>

	{#if selectedFile}
		<div class="mb-2 flex items-center text-sm text-gray-600">
			<span>📎 {selectedFile.name}</span>
			<button on:click={clearFile} class="ml-2 text-red-500 hover:text-red-700 cursor-pointer">✕</button>
		</div>
	{/if}

	<div class="flex space-x-2 mb-4">
		<input
			type="text"
			bind:value={newMessage}
			class="flex-grow border border-gray-300 rounded px-3 py-2 focus:outline-none focus:ring"
			placeholder="Type your message..."
		/>
		<label class="cursor-pointer bg-gray-200 hover:bg-gray-300 text-gray-700 font-semibold px-3 py-2 rounded flex items-center">
			📷
			<input
				type="file"
				accept="image/*"
				on:change={handleFileSelect}
				bind:this={fileInput}
				class="hidden"
			/>
		</label>
		<button
			on:click={sendMessage}
			disabled={uploading}
			class="cursor-pointer bg-blue-500 hover:bg-blue-600 text-white font-semibold px-4 py-2 rounded disabled:opacity-50"
		>
			{uploading ? 'Sending...' : 'Send'}
		</button>
	</div>

	<div class="border-t border-gray-200 pt-4 flex flex-wrap items-center gap-2">
		<button
			on:click={saveChat}
			class="cursor-pointer bg-green-500 hover:bg-green-600 text-white font-semibold px-4 py-2 rounded"
		>
			Save Chat
		</button>
		{#if saveStatus}
			<span class="text-sm text-gray-600">{saveStatus}</span>
		{/if}

		<div class="flex items-center gap-2 ml-auto">
			<input
				type="text"
				bind:value={loadChatId}
				class="border border-gray-300 rounded px-3 py-2 text-sm"
				placeholder="Chat ID"
			/>
			<button
				on:click={loadChat}
				class="cursor-pointer bg-purple-500 hover:bg-purple-600 text-white font-semibold px-4 py-2 rounded"
			>
				Load Chat
			</button>
		</div>
	</div>
</div>
